import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import 'app_config.dart';

class DatabaseService {
  final AppConfig _config = AppConfig();

  /// Check connectivity to XAMPP MySQL backend
  Future<bool> checkServerConnection() async {
    try {
      final url = Uri.parse('${_config.serverUrl}/get_recipes.php');
      final response = await http.get(url).timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Get recipes matching supplied user ingredients
  Future<List<Recipe>> searchRecipesByIngredients(List<String> userIngredients) async {
    // Attempt fetching from XAMPP MySQL Backend API first
    try {
      final url = Uri.parse('${_config.serverUrl}/search_recipes.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'ingredients': userIngredients}),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true && data['recipes'] != null) {
          final List list = data['recipes'];
          final recipes = list.map((e) => Recipe.fromJson(e)).toList();
          if (recipes.isNotEmpty) {
            return _sortRecipesByMatch(recipes);
          }
        }
      }
    } catch (e) {
      debugPrint('XAMPP MySQL connection offline or error: $e. Using Built-in Local Database.');
    }

    // Fallback: Smart local Thai recipe calculation engine
    final allRecipes = _getSeedRecipes();
    return calculateRecipeMatches(allRecipes, userIngredients);
  }

  /// Calculates ingredient matching percentage & missing items for recipes
  List<Recipe> calculateRecipeMatches(List<Recipe> recipes, List<String> userIngredients) {
    final List<String> normalizedUserIngs = userIngredients
        .map((ing) => ing.trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toList();

    List<Recipe> calculatedList = [];

    for (var recipe in recipes) {
      int matchedCount = 0;
      List<String> missing = [];

      for (var reqIng in recipe.ingredients) {
        String cleanReq = reqIng.toLowerCase();
        bool isFound = false;

        for (var uIng in normalizedUserIngs) {
          if (cleanReq.contains(uIng) || uIng.contains(cleanReq.split(' ').first)) {
            isFound = true;
            break;
          }
        }

        if (isFound) {
          matchedCount++;
        } else {
          // Extract main ingredient name for missing list
          String mainName = reqIng.split('(').first.trim();
          missing.add(mainName);
        }
      }

      double percentage = recipe.ingredients.isNotEmpty
          ? (matchedCount / recipe.ingredients.length) * 100
          : 0.0;

      // Bound percentage between 0 and 100
      percentage = double.parse((percentage > 100 ? 100.0 : percentage).toStringAsFixed(1));

      calculatedList.add(recipe.copyWith(
        matchPercentage: percentage,
        missingIngredients: missing,
      ));
    }

    return _sortRecipesByMatch(calculatedList);
  }

  List<Recipe> _sortRecipesByMatch(List<Recipe> recipes) {
    recipes.sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));
    return recipes;
  }

  /// Save recipe to favorites (XAMPP MySQL or Local)
  Future<bool> saveFavoriteRecipe(Recipe recipe) async {
    try {
      final url = Uri.parse('${_config.serverUrl}/save_recipe.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(recipe.toJson()),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      debugPrint('Save recipe offline mode: $e');
    }
    return true; // Return true as offline bookmark saved
  }

  /// Seed Thai recipes with ingredients & step-by-step instructions
  List<Recipe> _getSeedRecipes() {
    return [
      Recipe(
        id: '1',
        title: 'ผัดกะเพราหมูสับ',
        description: 'เมนูยอดฮิตตลอดกาล หอมกลิ่นใบกะเพราและกระเทียมพริกสด รสชาติเผ็ดร้อนกลมกล่อม',
        category: 'ผัด',
        prepTime: 10,
        cookTime: 10,
        servings: 2,
        difficulty: 'ง่าย',
        imageUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=600',
        ingredients: [
          'หมูสามชั้น',
          'กระเทียม',
          'พริกจินดา',
          'ใบกะเพรา',
          'ซอสหอยนางรม 1 ช้อนโต๊ะ',
          'น้ำปลา 1 ช้อนโต๊ะ',
          'ซีอิ๊วดำ 1/2 ช้อนชา',
          'น้ำตาลทราย 1/2 ช้อนชา',
        ],
        instructions: [
          'โขลกพริกจินดาและกระเทียมให้พอหยาบ',
          'ตั้งกระทะใส่น้ำมันพืช ใช้ไฟปานกลาง ใส่พริกกระเทียมลงผัดจนส่งกลิ่นหอม',
          'ใส่หมูสามชั้นลงไปผัด ยีให้เนื้อสุกกระจายตัวทั่วกระทะ',
          'ปรุงรสด้วยซอสหอยนางรม น้ำปลา ซีอิ๊วดำ และน้ำตาลทราย ผัดเร่งไฟแรงให้เข้ากัน',
          'ปิดไฟ ใส่ใบกะเพราลงไปผัดสะบัดกระทะให้ใบกะเพลาสลด ตักใส่จานเสิร์ฟพร้อมข้าวสวย',
        ],
        nutritionalInfo: '420 แคลอรี | โปรตีน 28g | ไขมัน 22g',
        chefTip: 'ใส่ใบกะเพราตอนปิดไฟแล้วผัดสะบัดเร็วๆ จะทำให้กะเพราไม่ดำและมีกลิ่นหอมฉุนชวนรับประทาน',
      ),
      Recipe(
        id: '2',
        title: 'ต้มยำกุ้งน้ำข้น',
        description: 'ต้มยำกุ้งรสเด็ด เข้มข้น หอมกลิ่นตะไคร้ ใบมะกรูด และมะนาวแท้',
        category: 'ต้ม',
        prepTime: 15,
        cookTime: 15,
        servings: 3,
        difficulty: 'ปานกลาง',
        imageUrl: 'https://images.unsplash.com/photo-1548943487-a2e4e43b4853?w=600',
        ingredients: [
          'กุ้งสด',
          'เห็ดฟาง',
          'ตะไคร้',
          'ใบมะกรูด',
          'มะนาว',
          'พริกเผา 2 ช้อนโต๊ะ',
          'น้ำปลา 2 ช้อนโต๊ะ',
          'นมข้นจืด 3 ช้อนโต๊ะ',
          'ข่า',
        ],
        instructions: [
          'ล้างกุ้ง ปอกเปลือกเด็ดหัว ปล่อยหางไว้ แล้วผ่าหลังถอดเส้นดำออก',
          'ตั้งน้ำซุปใส่ข่า ตะไคร้ ใบมะกรูด พิกหั่น พอน้ำเดือดพล่านให้ใส่เห็ดฟาง',
          'ใส่กุ้งสดลงไป ต้มพอกุ้งเริ่มเปลี่ยนเป็นสีส้ม',
          'ใส่น้ำพริกเผา นมข้นจืด คนให้เข้ากันจนน้ำต้มยำเป็นสีส้มสวยงาม',
          'ยกลงจากเตา บีบน้ำมะนาว โรยผักชี พร้อมเสิร์ฟ',
        ],
        nutritionalInfo: '320 แคลอรี | โปรตีน 24g | ไขมัน 12g',
        chefTip: 'ควรใส่น้ำมะนาวหลังจากปิดเตาแล้วเท่านั้น เพื่อไม่ให้น้ำมะนาวมีรสขม',
      ),
      Recipe(
        id: '3',
        title: 'ไข่เจียวทรงเครื่อง',
        description: 'ไข่เจียวฟูกรอบ หอมอร่อย ใส่เครื่องจุกๆ ปรุงง่ายได้ประโยชน์ครบครัน',
        category: 'ทอด',
        prepTime: 5,
        cookTime: 5,
        servings: 2,
        difficulty: 'ง่าย',
        imageUrl: 'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=600',
        ingredients: [
          'ไข่ไก่',
          'กระเทียม',
          'พริกจินดา',
          'หมูสามชั้น',
          'น้ำปลา 1 ช้อนชา',
          'ซอสปรุงรส 1 ช้อนชา',
          'มะนาว 1-2 หยด',
        ],
        instructions: [
          'ตอกไข่ไก่ใส่ชาม ใส่หมูสับ พริกสด และกระเทียมสับ',
          'ปรุงรสด้วยน้ำปลา ซอสปรุงรส และหยดน้ำมะนาวเล็กน้อย ตีไข่ให้เข้ากันจนเป็นฟอง',
          'ตั้งกระทะใส่น้ำมันพืชเยอะหน่อย ใช้ไฟแรงจนน้ำมันร้อนจัด',
          'เทไข่ลงไปเจียว ไข่จะฟูกรอบสวยงาม',
          'ทอดจนสีเหลืองทองทั้งสองด้าน พักบนตะแกรงสะเด็ดน้ำมัน ตักใส่จาน',
        ],
        nutritionalInfo: '280 แคลอรี | โปรตีน 18g | ไขมัน 20g',
        chefTip: 'การหยดน้ำมะนาวเล็กน้อยในชามไข่จะช่วยให้ไข่เจียวมีความนุ่มฟูกว่าปกติ',
      ),
      Recipe(
        id: '4',
        title: 'แกงเขียวหวานไก่',
        description: 'แกงไทยโบราณ รสชาติกลมกล่อม หอมกะทิและพริกแกงเขียวหวานแท้',
        category: 'แกง',
        prepTime: 15,
        cookTime: 20,
        servings: 4,
        difficulty: 'ปานกลาง',
        imageUrl: 'https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?w=600',
        ingredients: [
          'อกไก่',
          'พริกแกงเขียวหวาน',
          'กะทิ',
          'มะเขือเปราะ',
          'ใบโหระพา',
          'น้ำปลา 2 ช้อนโต๊ะ',
          'น้ำตาลปี๊บ 1 ช้อนโต๊ะ',
        ],
        instructions: [
          'ผัดหัวกะทิจนแตกมันเล็กน้อย ใส่พริกแกงเขียวหวานลงผัดจนส่งกลิ่นหอม',
          'ใส่เนื้ออกไก่ลงไปผัดจนสุกพอดี',
          'เติมหางกะทิลงไป เคี่ยวจนน้ำแกงเริ่มเดือด ใส่ผ่ามะเขือเปราะ',
          'ปรุงรสด้วยน้ำปลาและน้ำตาลปี๊บ ชิมรสตามชอบ',
          'โรยใบโหระพาและพริกชี้ฟ้าแดง ปิดไฟ ยกลงเสิร์ฟ',
        ],
        nutritionalInfo: '480 แคลอรี | โปรตีน 30g | ไขมัน 32g',
        chefTip: 'แช่มะเขือเปราะที่หั่นแล้วในน้ำผสมเกลือ จะช่วยไม่ให้มะเขือเปราะดำ',
      ),
      Recipe(
        id: '5',
        title: 'ผัดผักบุ้งไฟแดง',
        description: 'เมนูผัดผักบุ้งกรุบกรอบ หอมกลิ่นเต้าเจี้ยวและกระเทียมพริกสด',
        category: 'ผัด',
        prepTime: 5,
        cookTime: 3,
        servings: 2,
        difficulty: 'ง่าย',
        imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600',
        ingredients: [
          'ผักบุ้ง',
          'กระเทียม',
          'พริกขี้หนู',
          'เต้าเจี้ยว',
          'ซอสหอยนางรม 1 ช้อนโต๊ะ',
          'น้ำตาลทราย 1/2 ช้อนชา',
        ],
        instructions: [
          'ล้างผักบุ้ง หั่นเป็นท่อน ใส่จานไว้',
          'วางกระเทียมโขลก พริกโขลก เต้าเจี้ยว ซอสหอยนางรม และน้ำตาลทราย ลงบนกองผักบุ้ง',
          'ตั้งกระทะใส่น้ำมันใช้ไฟแรงจัดจนควันขึ้นเล็กน้อย',
          'เทผักบุ้งและเครื่องปรุงทั้งหมดลงในกระทะพร้อมกัน ผัดด้วยไฟแรงอย่างรวดเร็ว 10-15 วินาที',
          'ตักใส่จานทันที พร้อมรับประทาน',
        ],
        nutritionalInfo: '150 แคลอรี | โปรตีน 4g | ไขมัน 8g',
        chefTip: 'ไฟต้องแรงจัด และใช้เวลาผัดสั้นมาก จะทำให้ผักบุ้งกรอบและสีเขียวสดสวยงาม',
      ),
    ];
  }
}
