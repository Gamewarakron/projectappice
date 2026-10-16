# คู่มือการติดตั้ง XAMPP & MySQL Database สำหรับแอป Chef AI

คู่มือนี้แนะนำขั้นตอนการตั้งค่า **XAMPP (Apache + MySQL)** เพื่อใช้งานเป็น Backend Database สำหรับแอปพลิเคชัน

---

## 🛠️ ขั้นตอนการติดตั้งและตั้งค่า XAMPP

### 1. เปิดโปรแกรม XAMPP Control Panel
- เปิดโปรแกรม **XAMPP Control Panel**
- กดปุ่ม **Start** ที่โมดูล **Apache** และ **MySQL** ให้ขึ้นเป็นสีเขียว

---

### 2. สร้างฐานข้อมูล MySQL
1. เปิด เว็บบราวเซอร์ แล้วเข้าไปที่ [http://localhost/phpmyadmin](http://localhost/phpmyadmin)
2. กดแถบ **Import** (นำเข้า)
3. กดปุ่ม **Choose File** (เลือกไฟล์) แล้วเลือกไฟล์ `setup_database.sql` ในโฟลเดอร์นี้ (`projectappice/backend/xampp/setup_database.sql`)
4. กดปุ่ม **Go** (หรือ นำเข้า) ด้านล่างสุด
5. เมื่อเสร็จสิ้น คุณจะเห็นฐานข้อมูลชื่อ `food_app_db` พร้อมตาราง `recipes` และ `saved_recipes`

---

### 3. วางไฟล์ PHP API ลงใน XAMPP (`htdocs`)
1. ไปที่โฟลเดอร์ติดตั้ง XAMPP ของคุณ เช่น:
   - **Windows**: `C:\xampp\htdocs\`
   - **macOS**: `/Applications/XAMPP/htdocs/`
2. สร้างโฟลเดอร์ใหม่ชื่อ `food_app_api`
3. คัดลอกไฟล์ PHP จากโฟลเดอร์นี้ไปไว้ใน `htdocs/food_app_api/`:
   - `db_config.php`
   - `get_recipes.php`
   - `search_recipes.php`
   - `save_recipe.php`

---

### 4. ทดสอบการเชื่อมต่อ API บน Browser
เปิด Link บนเบราว์เซอร์เพื่อทดสอบ:
- [http://localhost/food_app_api/get_recipes.php](http://localhost/food_app_api/get_recipes.php)

หากปรากฏข้อมูลสูตรอาหารเป็นรูปแบบ JSON แสดงว่า XAMPP MySQL API พร้อมใช้งานสมบูรณ์!

---

## 📱 การเชื่อมต่อจากแอป Flutter
- **สำหรับ Android Emulator**: ในแอปจะใช้ URL `http://10.0.2.2/food_app_api` โดยอัตโนมัติ (10.0.2.2 คือ IP ของเครื่อง Host ใน Android Emulator)
- **สำหรับเครื่องจริง (Real Device)**: กดไอคอน **ตั้งค่า (Gear icon)** มุมขวาบนในแอป แล้วเปลี่ยน URL เป็น IP เครื่องคอมพิวเตอร์ของคุณ เช่น `http://192.168.1.50/food_app_api`
