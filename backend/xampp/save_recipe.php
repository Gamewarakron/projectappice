<?php
// save_recipe.php - Save/Bookmark a recipe into MySQL saved_recipes table
require_once 'db_config.php';

$input = json_decode(file_get_contents('php://input'), true);

if (!$input || empty($input['title'])) {
    echo json_encode(["success" => false, "message" => "Invalid input data"]);
    exit();
}

try {
    $recipeId = isset($input['id']) ? $input['id'] : null;
    $title = $input['title'];
    $recipeJson = json_encode($input, JSON_UNESCAPED_UNICODE);

    $stmt = $pdo->prepare("INSERT INTO saved_recipes (recipe_id, title, recipe_json) VALUES (:recipe_id, :title, :recipe_json)");
    $stmt->execute([
        ':recipe_id' => $recipeId,
        ':title' => $title,
        ':recipe_json' => $recipeJson
    ]);

    echo json_encode([
        "success" => true,
        "message" => "Saved recipe to MySQL successfully!",
        "saved_id" => $pdo->lastInsertId()
    ]);

} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "message" => "Error saving recipe: " . $e->getMessage()
    ]);
}
?>
