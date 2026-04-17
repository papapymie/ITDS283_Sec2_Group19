# Electric Home 🏠⚡

แอปพลิเคชัน Flutter สำหรับจัดการการใช้ไฟฟ้าและน้ำประปาภายในบ้าน 
พร้อมระบบติดตามการชำระเงินค่าสาธารณูปโภค

---

## ฟีเจอร์หลัก

- **USAGE TIMER** — จับเวลาการใช้งานเครื่องใช้ไฟฟ้าและน้ำประปา แยกตามประเภท
- **ADD DEVICE** — เพิ่ม/ลบเครื่องใช้ไฟฟ้าและน้ำประปาของแต่ละบัญชีผู้ใช้
- **PAYMENT TRACKING** — บันทึกและติดตามประวัติการชำระเงินค่าสาธารณูปโภครายเดือน
- **PAYMENT LOCATION** — แสดงสถานที่รับชำระเงิน พร้อมระบุระยะทางจาก GPS หรือที่อยู่ใน Profile
- **CALCULATE** — คำนวณค่าไฟฟ้าและน้ำประปา
- **ANNOUNCEMENT** — ประกาศและข่าวสารจากระบบ
- **REVIEW** — รีวิวและความคิดเห็นจากผู้ใช้

---

## เทคโนโลยีที่ใช้

| เทคโนโลยี | การใช้งาน |
|---|---|
| Flutter | Framework หลักสำหรับพัฒนาแอป |
| Firebase Auth | ระบบ Login/Logout และจัดการบัญชีผู้ใช้ |
| Cloud Firestore | เก็บข้อมูลเครื่องใช้ ประวัติชำระเงิน รีวิว และสถานที่ |
| Provider | จัดการ State ของแอป |
| Geolocator | ระบุตำแหน่ง GPS ของผู้ใช้ |
| Geocoding | แปลงที่อยู่เป็นพิกัด |

---

## โครงสร้าง Firebase
Firestore
├── users/
│   └── {user_id}/
│       ├── name
│       ├── profile_image
│       ├── address
│       │
│       ├── devices/                  # เครื่องใช้ไฟฟ้าและน้ำประปาของผู้ใช้
│       │   └── {device_id}/
│       │       ├── createdAt
│       │       ├── name
│       │       ├── type
│       │       └── iconKey
│       │
│       ├── payments/                 # ประวัติการชำระเงิน
│       │   └── {payment_id}/
│       │       ├── date
│       │       ├── amount
│       │       └── monthKey
│       │
│       └── favorite_locations/       # สถานที่ชำระเงินที่ชื่นชอบ
│           └── {location_id}/
│               └── locationId
│
├── announcements/                   # ประกาศ
│   └── {announcement_id}/
│       ├── created_at
│       ├── date
│       ├── isPinned
│       └── title
│
├── electricity_usage/              # ข้อมูลการใช้ไฟฟ้า/น้ำประปา
│   └── {usage_id}/
│       ├── user_id
│       ├── location
│       ├── recorded_at
│       ├── electricity_units
│       ├── electricity_cost
│       ├── water_units
│       ├── water_cost
│       └── total
│
├── payment_location/               # สถานที่รับชำระเงินทั้งหมด
│   └── {location_id}/
│       ├── name
│       ├── address
│       ├── latitude
│       └── longitude
│
└── reviews/                        # รีวิวจากผู้ใช้
    └── {review_id}/
        ├── user_id
        ├── name
        ├── photo_data
        ├── stars
        ├── text
        └── created_at
---

## วิธีติดตั้งและรันโปรเจกต์

### 1. Clone โปรเจกต์
```bash
git clone https://github.com/yourusername/electric_home.git
cd electric_home
```

### 2. ติดตั้ง dependencies
```bash
flutter pub get
```

### 3. เชื่อมต่อ Firebase
- ดาวน์โหลด `google-services.json` จาก Firebase Console
- วางไว้ที่ `android/app/google-services.json`

### 4. รันแอป
```bash
# รันในมือถือผ่าน USB
flutter run

# รันในมือถือผ่าน WiFi
adb tcpip 5555
adb connect <IP มือถือ>:5555
flutter run
```

---

## โครงสร้าง Project
lib/
├── main.dart
├── firebase_options.dart
├── fonts/
│   └── my_flutter_app_icons.dart    ← Custom icons
├── providers/
│   ├── device_provider.dart         ← DeviceType, TimerProvider
│   └── payment_provider.dart        ← ประวัติการชำระเงิน
├── screens/
│   ├── home_screen.dart
│   └── login_screen.dart
│   └── loading_screen.dart
│   └── add_electrical_water_screen.dart
│   └── add_device_screen.dart
│   └── timer_screen.dart
│   └── tracking_screen.dart
│   └── payment_location_screen.dart
│   └── location_map_screen.dart
│   └── calculate_screen.dart
│   └── announcement_screen.dart
│   └── review_screen.dart
│   └── profile_screen.dart
---

---

## ระบบบัญชีผู้ใช้

- ผู้ใช้แต่ละคน login ด้วย Firebase Auth
- ข้อมูลเครื่องใช้ สถานที่โปรดสำหรับการชำระเงิน และประวัติการชำระเงินแยกตาม `user_id` ของแต่ละบัญชี
- ผู้ใช้คนอื่นไม่สามารถเห็นข้อมูลของกันและกันได้

---

## 📝 Git Commands ที่ใช้บ่อย

```bash
git add .
git commit -m "ใส่ข้อความอธิบายตรงนี้"
git push
```

---

## Getting Started

This project is a starting point for a Flutter application.

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/).
