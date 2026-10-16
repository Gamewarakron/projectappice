-- =========================================================
-- SQL Database Setup for Food AI App (XAMPP / MySQL)
-- Database Name: food_app_db
-- =========================================================

CREATE DATABASE IF NOT EXISTS `food_app_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `food_app_db`;

-- 1. Table: recipes
CREATE TABLE IF NOT EXISTS `recipes` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `title` VARCHAR(255) NOT NULL,
  `description` TEXT,
  `category` VARCHAR(100) DEFAULT 'อาหารไทย',
  `prep_time` INT DEFAULT 10,
  `cook_time` INT DEFAULT 15,
  `servings` INT DEFAULT 2,
  `difficulty` VARCHAR(50) DEFAULT 'ง่าย',
  `image_url` VARCHAR(500) DEFAULT '',
  `ingredients_json` JSON NOT NULL,
  `instructions_json` JSON NOT NULL,
  `nutritional_info` VARCHAR(255) DEFAULT '350 แคลอรี',
  `chef_tip` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Table: saved_recipes (Favorites/User Created)
CREATE TABLE IF NOT EXISTS `saved_recipes` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `recipe_id` INT,
  `title` VARCHAR(255) NOT NULL,
  `recipe_json` JSON NOT NULL,
  `saved_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Seed Initial Recipes
INSERT INTO `recipes` (`title`, `description`, `category`, `prep_time`, `cook_time`, `servings`, `difficulty`, `image_url`, `ingredients_json`, `instructions_json`, `nutritional_info`, `chef_tip`) VALUES
(
  'ผัดกะเพราหมูสับ',
  'เมนูยอดฮิตตลอดกาล หอมกลิ่นใบกะเพราและกระเทียมพริกสด รสชาติเผ็ดร้อนกลมกล่อม',
  'ผัด',
  10,
  10,
  2,
  'ง่าย',
  'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=600',
  '["หมูสามชั้น", "กระเทียม", "พริกจินดา", "ใบกะเพรา", "ซอสหอยนางรม 1 ช้อนโต๊ะ", "น้ำปลา 1 ช้อนโต๊ะ"]',
  '["โขลกพริกจินดาและกระเทียมให้พอหยาบ", "ตั้งกระทะใส่น้ำมันพืช ใช้ไฟปานกลาง ใส่พริกกระเทียมลงผัดจนหอม", "ใส่หมูสามชั้นลงไปผัด ยีให้เนื้อสุกทั่วกระทะ", "ปรุงรสด้วยซอสหอยนางรม น้ำปลา ผัดเร่งไฟแรง", "ใส่ใบกะเพราลงไปผัดสะบัดกระทะ ตักใส่จาน"]',
  '420 แคลอรี | โปรตีน 28g',
  'ใส่ใบกะเพราตอนปิดไฟผัดสะบัดเร็วๆ ใบกะเพราจะไม่ดำ'
),
(
  'ต้มยำกุ้งน้ำข้น',
  'ต้มยำกุ้งรสเด็ด เข้มข้น หอมกลิ่นตะไคร้ ใบมะกรูด และมะนาวแท้',
  'ต้ม',
  15,
  15,
  3,
  'ปานกลาง',
  'https://images.unsplash.com/photo-1548943487-a2e4e43b4853?w=600',
  '["กุ้งสด", "เห็ดฟาง", "ตะไคร้", "ใบมะกรูด", "มะนาว", "พริกเผา 2 ช้อนโต๊ะ", "นมข้นจืด 3 ช้อนโต๊ะ"]',
  '["ล้างกุ้ง ปอกเปลือกผ่าหลังถอดเส้นดำออก", "ตั้งน้ำซุปใส่ข่า ตะไคร้ ใบมะกรูด พอเดือดใส่เห็ดฟางและกุ้งสด", "ใส่น้ำพริกเผา นมข้นจืด คนให้เข้ากัน", "ยกลงจากเตา บีบน้ำมะนาว โรยผักชี"]',
  '320 แคลอรี | โปรตีน 24g',
  'ใส่น้ำมะนาวหลังจากปิดเตาแล้วเท่านั้น เพื่อไม่ให้มีรสขม'
),
(
  'ไข่เจียวทรงเครื่อง',
  'ไข่เจียวฟูกรอบ หอมอร่อย ใส่เครื่องจุกๆ ปรุงง่ายได้ประโยชน์ครบครัน',
  'ทอด',
  5,
  5,
  2,
  'ง่าย',
  'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=600',
  '["ไข่ไก่", "กระเทียม", "พริกจินดา", "หมูสามชั้น", "น้ำปลา 1 ช้อนชา"]',
  '["ตอกไข่ไก่ใส่ชาม ใส่หมูสับ พริกสด และกระเทียมสับ", "ปรุงรสด้วยน้ำปลา ตีไข่ให้เข้ากันจนเป็นฟอง", "ตั้งกระทะใส่น้ำมันใช้ไฟแรงจนน้ำมันร้อนจัด", "เทไข่ลงไปเจียวจนสีเหลืองทองทั้งสองด้าน"]',
  '280 แคลอรี | โปรตีน 18g',
  'หยดน้ำมะนาวเล็กน้อยในชามไข่ จะช่วยให้ไข่เจียวฟูกรอบขึ้น'
),
(
  'ผัดผักบุ้งไฟแดง',
  'เมนูผัดผักบุ้งกรุบกรอบ หอมกลิ่นเต้าเจี้ยวและกระเทียมพริกสด',
  'ผัด',
  5,
  3,
  2,
  'ง่าย',
  'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600',
  '["ผักบุ้ง", "กระเทียม", "พริกขี้หนู", "เต้าเจี้ยว", "ซอสหอยนางรม 1 ช้อนโต๊ะ"]',
  '["ล้างผักบุ้ง หั่นเป็นท่อน ใส่จานไว้", "วางกระเทียมโขลก พริก เต้าเจี้ยว ซอสหอยนางรม ลงบนกองผักบุ้ง", "ตั้งกระทะใส่น้ำมันใช้ไฟแรงจัดจนควันขึ้น", "เทผักบุ้งลงผัดเร็วนาน 10-15 วินาที แล้วตักใส่จาน"]',
  '150 แคลอรี | โปรตีน 4g',
  'ใช้ไฟแรงจัดและผัดด้วยเวลาสั้นๆ ผักบุ้งจะกรอบสีสด'
);
