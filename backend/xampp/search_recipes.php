<?php
// search_recipes.php - Match recipes from MySQL based on user ingredients
require_once 'db_config.php';

$input = json_decode(file_get_contents('php://input'), true);
$userIngredients = isset($input['ingredients']) && is_array($input['ingredients']) ? $input['ingredients'] : [];

try {
    $stmt = $pdo->query("SELECT * FROM recipes ORDER BY id DESC");
    $recipes = $stmt->fetchAll();

    $matchedList = [];

    // Clean user ingredients for comparison
    $cleanUserIngs = array_map(function($ing) {
        return mb_strtolower(trim($ing), 'UTF-8');
    }, $userIngredients);

    foreach ($recipes as $row) {
        $requiredIngs = json_decode($row['ingredients_json'], true);
        if (!is_array($requiredIngs)) $requiredIngs = [];

        $matchedCount = 0;
        $missing = [];

        foreach ($requiredIngs as $req) {
            $cleanReq = mb_strtolower(trim($req), 'UTF-8');
            $found = false;

            foreach ($cleanUserIngs as $userIng) {
                if (empty($userIng)) continue;
                if (mb_strpos($cleanReq, $userIng) !== false || mb_strpos($userIng, explode(' ', $cleanReq)[0]) !== false) {
                    $found = true;
                    break;
                }
            }

            if ($found) {
                $matchedCount++;
            } else {
                $parts = explode('(', $req);
                $missing[] = trim($parts[0]);
            }
        }

        $totalReq = count($requiredIngs);
        $percentage = $totalReq > 0 ? ($matchedCount / $totalReq) * 100.0 : 0.0;
        if ($percentage > 100.0) $percentage = 100.0;

        $matchedList[] = [
            'id' => (string)$row['id'],
            'title' => $row['title'],
            'description' => $row['description'],
            'category' => $row['category'],
            'prep_time' => (int)$row['prep_time'],
            'cook_time' => (int)$row['cook_time'],
            'servings' => (int)$row['servings'],
            'difficulty' => $row['difficulty'],
            'image_url' => $row['image_url'],
            'ingredients' => $requiredIngs,
            'instructions' => json_decode($row['instructions_json']),
            'nutritional_info' => $row['nutritional_info'],
            'chef_tip' => $row['chef_tip'],
            'match_percentage' => round($percentage, 1),
            'missing_ingredients' => $missing
        ];
    }

    // Sort by match percentage descending
    usort($matchedList, function($a, $b) {
        return $b['match_percentage'] <=> $a['match_percentage'];
    });

    echo json_encode([
        "success" => true,
        "query_ingredients" => $userIngredients,
        "total" => count($matchedList),
        "recipes" => $matchedList
    ]);

} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "message" => "Error searching recipes: " . $e->getMessage()
    ]);
}
?>
