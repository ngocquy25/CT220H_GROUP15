# BÁO CÁO DỰ ÁN – GomĐơn (Phần Dev B)
**Môn học:** CT220H – Lập trình Đa nền tảng Di động  
**Nhóm:** Dev B (app_driver, app_merchant, app_admin)  
**Ngày hoàn thiện:** 13/07/2026  
**Công cụ:** Flutter 3.44.0 · Dart 3.12.0 · Firebase Firestore · Android Studio

---

## I. CẤU TRÚC DỰ ÁN

```
gom_don_project/
├── shared/                    # Models & Services dùng chung
│   └── lib/
│       ├── models/            # 5 model: user, hub, room, order, merchant
│       ├── services/          # FirebaseCoreService
│       └── test/              # MockData (dữ liệu giả lập)
│
├── app_driver/                # ← Dev B: Phân hệ Tài xế
│   └── lib/
│       ├── main.dart          # Home screen với gradient + animation
│       └── src/features/
│           ├── pooling/       # Danh sách chuyến xe (Mục 7)
│           └── delivery/      # Xác thực giao hàng (Mục 8)
│
├── app_merchant/              # ← Dev B: Phân hệ Chủ quán
│   └── lib/
│       ├── main.dart          # Màn hình chọn quán (Login giả lập)
│       └── features/
│           └── bulk_order/    # Bếp xem đơn tổng (Mục 9)
│
└── app_admin/                 # ← Dev B: Phân hệ Quản trị viên
    └── lib/
        ├── main.dart          # Dashboard Admin (SliverAppBar + Guide)
        └── features/
            ├── hub_management/          # Quản lý Hub (Mục 10)
            ├── financial_reconciliation/ # Đối soát tài chính (Mục 11)
            └── mock_data_seeder.dart    # Công cụ nạp data test
```

---

## II. VẤN ĐỀ ĐÃ PHÁT HIỆN VÀ XỬ LÝ

### 1. Lỗi Build nghiêm trọng – Unicode trong đường dẫn

**Nguyên nhân:**  
Thư mục cha chứa tiếng Việt có dấu: `CT220H_Lập trình nền tảng đa di động`.  
Flutter trên Windows không thể tạo URI cho file `dart_plugin_registrant.dart`.

```
ArgumentError: Invalid argument(s): Illegal character in path
#0  _Uri._checkWindowsPathReservedCharacters
```

**Cách khắc phục:**  
Copy toàn bộ thư mục `gom_don_project/` sang đường dẫn không có tiếng Việt:
```
C:\Projects\gom_don_project\
```
Sau đó mở lại project trong Android Studio từ đường dẫn mới.

---

### 2. Firebase khởi tạo crash nếu thiếu google-services.json

**Trước:**  
```dart
await Firebase.initializeApp(); // Crash nếu không có config
```

**Sau:**  
```dart
// shared/lib/services/firebase_core.dart
try {
  await Firebase.initializeApp();
  _initialized = true;
} catch (e) {
  debugPrint('⚠️ Firebase init failed: $e → Chạy chế độ MOCK');
}
```
App vẫn chạy bình thường và tự dùng `MockData` khi Firebase chưa cấu hình.

---

### 3. hub_management_controller – Chỉ dùng Mock, không ghi Firestore

**Trước:** Controller import `MockData` và chỉ lưu vào danh sách trong RAM.  
**Sau:** Ghi Hub lên `Firestore collection 'hubs'` với `maHub` tự sinh; fallback về mock khi Firebase không khả dụng.

---

### 4. reconciliation_controller – Excel chỉ là mock in log

**Trước:** Trả về đường dẫn giả, không tạo file thật.  
**Sau:** Sử dụng package `excel` để tạo file thật với 2 sheet:
- **Sheet 1:** Toàn bộ đơn hàng (15 cột)
- **Sheet 2:** Tổng kết theo quán + tính chiết khấu

---

### 5. kitchen_dashboard_controller – Bếp thấy đơn của mọi quán

**Trước:** Query Firestore không lọc theo quán → nhà bếp quán A thấy đơn quán B.  
**Sau:** Thêm tham số `maQuan` để filter:
```dart
Future<Map<String, int>> layDonTong(String maPhong, {String? maQuan}) async {
  if (maQuan != null) {
    query = query.where('MaQuan', isEqualTo: maQuan);
  }
  ...
}
```

---

## III. LOGIC NGHIỆP VỤ CHI TIẾT

### 📋 Mục 7 – Danh sách chuyến xe (app_driver/pooling)

**Màn hình:** `TripPoolScreen`  
**Controller:** `TripPoolController`

**Logic:**
1. Truy vấn Firestore: `rooms.where('TrangThaiPhong', '==', 'Thành công').where('MaTaiXe', isNull: true)`
2. Chỉ hiển thị phòng **chưa có tài xế nhận** (MaTaiXe == null)
3. Khi tài xế bấm **[Nhận Chuyến]**:
   - Dùng **Firestore Transaction** để tránh race condition
   - Kiểm tra lại `MaTaiXe` trong transaction → nếu đã bị lấy → `return false`
   - Nếu còn trống → ghi `MaTaiXe = 'DRIVER_TEST'` + xóa khỏi danh sách
   - Batch update tất cả `orders` trong phòng: gán `MaTaiXe`, `TenTaiXe`
4. Sau khi nhận thành công → hỏi "Giao ngay?" → mở `VerificationScreen`

**Bảo vệ tính nguyên tử (Atomicity):**
```dart
await _db.runTransaction<bool>((transaction) async {
  final roomSnapshot = await transaction.get(roomRef);
  if (roomSnapshot.data()?['MaTaiXe'] != null) return false; // đã bị lấy
  transaction.update(roomRef, {'MaTaiXe': maTaiXe});
  return true;
});
```

---

### 📋 Mục 8 – Xác thực giao hàng PIN/QR (app_driver/delivery)

**Màn hình:** `VerificationScreen`  
**Controller:** `VerificationController`

**Logic:**
1. Load danh sách phòng đã nhận của tài xế (`rooms.where('MaTaiXe', == 'DRIVER_TEST')`)
2. Với mỗi phòng → load danh sách đơn hàng (`orders.where('MaPhong', == maPhong)`)
3. Với mỗi đơn, tài xế xác nhận bằng **1 trong 2 cách**:

**Cách A – Nhập mã PIN:**
```dart
if (pinNhap.trim() == pinDung.trim()) {
  await _db.collection('orders').doc(maDonHang).update({
    'TrangThaiDonHang': 'Đã giao',
  });
  return true;
}
```

**Cách B – Quét QR:**
```dart
// QR chứa mã PIN hoặc mã đơn hàng đều được chấp nhận
if (qrData == pinDung || qrData == maDonHang) {
  return xacNhanhPin(maDonHang, pinDung, pinDung);
}
```

4. Giao diện hiển thị **progress bar** trên AppBar (số đơn đã giao / tổng)
5. Mỗi đơn chuyển sang trạng thái **"Đã giao"** → cập nhật màu xanh ngay lập tức

---

### 📋 Mục 9 – Bếp xem đơn tổng (app_merchant/bulk_order)

**Màn hình:** `KitchenDashboardScreen`  
**Controller:** `KitchenDashboardController`

**Logic Gom Nhóm (Group By) không cần bảng tổng riêng:**
```
Đầu vào: Tất cả orders thuộc maPhong & maQuan có TrangThaiDonHang == "Thành công"
Xử lý:   Duyệt từng OrderItem → cộng dồn SoLuong theo TenMon
Đầu ra:  Map<TenMon, TongSoLuong> → {"Cơm sườn trứng": 3, "Nước mía": 2, ...}
```

**Flow nghiệp vụ:**
1. Màn hình chọn quán (Login giả lập) → truyền `maQuan` vào controller
2. Chọn phòng từ dropdown → load đơn tổng theo phòng + quán
3. Hiển thị:
   - **Banner thời gian** (animation pulse sau 10:00)
   - **Thống kê nhanh:** Số khách / Loại món / Tổng suất
   - **Danh sách món theo số lượng** (gom nhóm)
   - **Ghi chú đặc biệt** từng khách (VD: "Ít cơm", "Không hành")
4. Bấm **[Bếp xong → Gọi Tài Xế]**:
   - Cập nhật `rooms/{maPhong}.TrangThaiBep = 'Xong'` lên Firestore
   - Tài xế có thể polling/lắng nghe để biết hàng đã sẵn sàng

---

### 📋 Mục 10 – Quản lý Hub (app_admin/hub_management)

**Màn hình:** `HubManagementScreen`  
**Controller:** `HubManagementController`

**CRUD Firestore:**
| Hành động | Firestore operation |
|-----------|---------------------|
| Tạo Hub | `hubs.doc(maHub).set(hubModel.toJson())` |
| Đọc Hub | `hubs.orderBy('TenHub').get()` |
| Bật/Tắt Hub | `hubs.doc(maHub).update({'DangHoatDong': bool})` |
| Xóa Hub | `hubs.doc(maHub).delete()` |

**Schema Firestore collection `hubs`:**
```json
{
  "MaHub": "HUB3391827",
  "TenHub": "Tòa nhà Viettel Cần Thơ",
  "ViDo": 10.0341,
  "KinhDo": 105.7469,
  "BanKinhMacDinh": 500,
  "DiaChi": "166 Trần Hưng Đạo, Ninh Kiều, Cần Thơ",
  "DangHoatDong": true
}
```

**Ý nghĩa nghiệp vụ:**  
Hub là điểm giao hàng cố định (sảnh tòa nhà/công ty). App User dùng GPS + công thức Haversine để tìm Hub gần nhất trong bán kính 500m, bắt buộc khách chọn trước khi đặt đơn.

---

### 📋 Mục 11 – Đối soát Tài chính (app_admin/financial_reconciliation)

**Màn hình:** `ReconciliationScreen`  
**Controller:** `ReconciliationController`

**Logic xuất Excel (package `excel` + `path_provider`):**
```
Sheet 1 "Danh Sach Don Hang":
  Cột: MaDonHang | NgayGiao | TenKhach | SĐT | TenQuan | TaiXe | Phong
       CaiDat | TongTienMon | PhiShipGoc | PhiShipThucTe | TongTT | TamKhoa | Hoan | TrangThai

Sheet 2 "Tong Ket Theo Quan":
  Cột: TenQuan | SoDon | TongDoanhThu | TyLeCK(%) | TienCK
  Logic: TienCK = TongDoanhThu × 0.15 → Admin chuyển khoản thủ công
```

**Filter theo ngày:**
```dart
Future<List<OrderModel>> layLichSuDon({DateTime? tuNgay, DateTime? denNgay})
```
Admin chọn khoảng ngày → hệ thống lọc theo `ngayGiao` để đối soát theo tháng.

**Tại sao không tính tự động trên hệ thống?**  
Theo thiết kế nghiệp vụ: tránh phức tạp hóa hệ thống backend. Admin export Excel → dùng công thức Excel để tính toán và chuyển khoản thủ công cho từng đối tác.

---

## IV. CÁC FILE ĐÃ THAY ĐỔI / TẠO MỚI

| File | Trạng thái | Mô tả |
|------|-----------|-------|
| `shared/lib/services/firebase_core.dart` | 🔧 Sửa | Thêm graceful fallback khi thiếu google-services.json |
| `app_admin/lib/main.dart` | 🔧 Sửa | SliverAppBar, status banner, test guide |
| `app_admin/lib/features/hub_management/hub_management_controller.dart` | 🔧 Sửa | Kết nối Firestore thật + CRUD đầy đủ |
| `app_admin/lib/features/hub_management/hub_management_screen.dart` | 🔧 Sửa | Stats header, animated form, delete button |
| `app_admin/lib/features/financial_reconciliation/reconciliation_controller.dart` | 🔧 Sửa | Firestore + Excel 2 sheet thật |
| `app_admin/lib/features/financial_reconciliation/reconciliation_screen.dart` | 🔧 Sửa | Tab list + tab tổng kết, filter ngày |
| `app_merchant/lib/main.dart` | 🔧 Sửa | Thêm màn hình chọn quán (Login giả lập) |
| `app_merchant/lib/features/bulk_order/kitchen_dashboard_controller.dart` | 🔧 Sửa | Thêm filter MaQuan, Firestore fallback |
| `app_merchant/lib/features/bulk_order/kitchen_dashboard_screen.dart` | 🔧 Sửa | Animated banner, quick stats, progress |
| `app_driver/lib/main.dart` | 🔧 Sửa | Gradient home + animation |
| `app_driver/lib/src/features/pooling/trip_pool_screen.dart` | 🔧 Sửa | Shimmer loading, info chips, metric cards |
| `app_driver/lib/src/features/delivery/verification_screen.dart` | 🔧 Sửa | Progress bar, animated cards, per-order loading |

---

## V. LUỒNG DỮ LIỆU FIRESTORE

```
[Admin] NẠP DATA (MockDataSeeder)
    ↓ batch.commit()
Firestore: rooms/{ROOM_001..004} + orders/{ORD_1001..ORD_OLD_01}

[Merchant App] 
  → Chọn quán (QA001)
  → Query: orders WHERE MaPhong=ROOM_001 AND MaQuan=QA001
  → Gom nhóm: {CơmSường: 2}
  → Bấm [Xong] → rooms/ROOM_001.TrangThaiBep = 'Xong'

[Driver App - Trip Pool]
  → Query: rooms WHERE TrangThaiPhong=ThanhCong AND MaTaiXe=null
  → Hiển thị: ROOM_001 (chờ nhận)
  → Bấm [Nhận] → Transaction → rooms/ROOM_001.MaTaiXe = 'DRIVER_TEST'
  → Batch: orders trong ROOM_001.MaTaiXe = 'DRIVER_TEST'

[Driver App - Verification]
  → Query: rooms WHERE MaTaiXe=DRIVER_TEST → ROOM_003
  → Load: orders WHERE MaPhong=ROOM_003 → ORD_1003
  → Nhập PIN 9999 → orders/ORD_1003.TrangThaiDonHang = 'Đã giao'

[Admin - Đối soát]
  → Query: orders (tất cả)
  → Filter theo ngày → Xuất Excel 2 sheet
```

---

## VI. MOCK DATA KIỂM THỬ

| ID | Collection | Mục đích |
|----|-----------|---------|
| ROOM_001 | rooms | Phòng thành công, chưa có tài xế → test nhận chuyến |
| ROOM_002 | rooms | Phòng đã bị DRIVER_ANOTHER_999 lấy → không hiển thị |
| ROOM_003 | rooms | Phòng đã giao cho DRIVER_TEST → test xác nhận giao |
| ROOM_004 | rooms | Dữ liệu tháng 6 → test đối soát lịch sử |
| ORD_1001 | orders | Phòng 001, QA001, PIN 1234, Trạng thái: Thành công |
| ORD_1002 | orders | Phòng 001, QA002, PIN 5678, Trạng thái: Thành công |
| ORD_1003 | orders | Phòng 003, QA001, PIN 9999, Trạng thái: Thành công |
| ORD_OLD_01 | orders | Phòng 004, QA001, PIN 1111, Trạng thái: Đã giao |

---

## VII. HƯỚNG DẪN CHẠY DỰ ÁN

### Bước 1: Fix lỗi đường dẫn Unicode
```powershell
# Copy project sang đường dẫn không có tiếng Việt
xcopy /E /I "D:\Năm 3\HKIII\...\gom_don_project" "C:\Projects\gom_don_project"
```
Mở Android Studio → File → Open → chọn `C:\Projects\gom_don_project\app_driver`

### Bước 2: Cấu hình Firebase (nếu có)
Đặt file `google-services.json` vào:
- `app_driver/android/app/google-services.json`
- `app_merchant/android/app/google-services.json`
- `app_admin/android/app/google-services.json`

### Bước 3: Cài dependencies
```bash
# Trong mỗi thư mục app
flutter pub get
```

### Bước 4: Chạy từng phân hệ
```bash
# Chạy admin trước để nạp data
cd app_admin && flutter run

# Chạy tài xế
cd app_driver && flutter run

# Chạy chủ quán
cd app_merchant && flutter run
```

### Bước 5: Luồng kiểm thử
1. **Admin App** → Nhấn "NẠP DATA KIỂM THỬ" → Confirm
2. **Merchant App** → Chọn "Cơm Tấm Bà Ba" → Xem đơn ROOM_001 → Bấm xong
3. **Driver App** → Xem danh sách → Nhận ROOM_001 (ROOM_002 không thấy)
4. **Driver App** → Chuyến của tôi → ROOM_003 → Nhập PIN **9999** → Đã giao
5. **Admin App** → Đối soát → Kiểm tra trạng thái → Xuất Excel

---

## VIII. PHÂN TÍCH KỸ THUẬT

### Patterns sử dụng
| Pattern | Áp dụng ở |
|---------|---------|
| Repository Pattern | Controllers đều có fallback mock |
| Firestore Transaction | `nhanChuyen()` – tránh race condition |
| Batch Write | Cập nhật nhiều orders cùng lúc |
| GroupBy (client-side) | `layDonTong()` – không cần bảng trung gian |
| Graceful Degradation | Firebase init fail → app vẫn chạy với mock |

### Bảo mật cơ bản
- Tài xế chỉ thấy chuyến chưa có người nhận (`MaTaiXe == null`)
- Chủ quán chỉ thấy đơn của quán mình (`MaQuan == maQuanHienTai`)
- PIN 4 số không được hiển thị trên giao diện tài xế (chỉ show gợi ý trong dev mode)

---

*Báo cáo được tạo tự động bởi Antigravity AI – 13/07/2026*
