<?php
// get_recipes.php - Get list of all recipes from MySQL DB
require_once 'db_config.php';

try {
    $stmt = $pdo->query("SELECT * FROM recipes ORDER BY id DESC");
    $recipes = $stmt->fetchAll();

    $formattedRecipes = array_map(function($row) {
        return [
            'id' => (string)$row['id'],
            'title' => $row['title'],
            'description' => $row['description'],
            'category' => $row['category'],
            'prep_time' => (int)$row['prep_time'],
            'cook_time' => (int)$row['cook_time'],
            'servings' => (int)$row['servings'],
            'difficulty' => $row['difficulty'],
            'image_url' => $row['image_url'],
            'ingredients' => json_decode($row['ingredients_json']),
            'instructions' => json_decode($row['instructions_json']),
            'nutritional_info' => $row['nutritional_info'],
            'chef_tip' => $row['chef_tip'],
            'match_percentage' => 100.0,
            'missing_ingredients' => []
        ];
    }, $recipes);

    echo json_encode([
        "success" => true,
        "total" => count($formattedRecipes),
        "recipes" => $formattedRecipes
    ]);
} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "message" => "Error fetching recipes: " . $e->getMessage()
    ]);
}
?>
