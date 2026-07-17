# Kế hoạch hoàn thiện Dev B – GomĐơn (Driver / Merchant / Admin)

## Tổng quan vấn đề

Dự án có 3 phân hệ do **Dev B phụ trách**: `app_driver`, `app_merchant`, `app_admin`.  
Khi chạy trên Android Studio, cả 3 bị lỗi **build** với thông báo:

> `ArgumentError: Invalid argument(s): Illegal character in path`

Nguyên nhân: **đường dẫn thư mục cha chứa ký tự tiếng Việt có dấu** (`CT220H_Lập trình nền tảng đa di động`), Flutter trên Windows không xử lý được khi sinh file `dart_plugin_registrant.dart`.

Ngoài lỗi đường dẫn, còn một số vấn đề code-level cần hoàn thiện:

---

## ⚠️ Vấn đề cần xem xét

> [!IMPORTANT]
> **Lỗi đường dẫn Unicode** là lỗi của Flutter toolchain trên Windows. Cách xử lý dứt điểm là **copy toàn bộ thư mục `gom_don_project/` sang một đường dẫn không có tiếng Việt** (VD: `C:\Projects\gom_don_project\`). 
> Nếu không muốn di chuyển, có thể tạo symbolic link ngắn tại `C:\GomDon\` trỏ đến thư mục gốc.

> [!WARNING]
> Firebase cần file `google-services.json` trong thư mục `android/app/` của mỗi phân hệ để kết nối thực. Hiện tại code dùng `Firebase.initializeApp()` không có options — sẽ crash khi chạy thật. Cần có file cấu hình hoặc tích hợp `firebase_options.dart`.

---

## Danh sách vấn đề code cần sửa

### 1. `app_driver` – Phân hệ Tài xế

**Vấn đề phát hiện:**
- `trip_pool_screen.dart` tham chiếu `room.soThanhVien`, `room.tongSoMon`, `room.ngayGiao` → **Đã có trong `RoomModel`** ✅
- `VerificationScreen` nhận tham số `maPhong` optional nhưng gọi không truyền từ `main.dart` → OK vì có xử lý null
- Không có màn hình **đăng nhập tài xế** (dùng hardcoded `'DRIVER_TEST'`)

**Cần bổ sung:**
- Hoàn thiện UX màn hình `TripPoolScreen`: thêm thông tin Hub, tên quán, thời gian tạo
- Hoàn thiện `VerificationScreen`: cải thiện UI hiển thị màu trạng thái
- Thêm `firebase_options.dart` (hoặc mock initialization)

---

### 2. `app_merchant` – Phân hệ Chủ quán

**Vấn đề phát hiện:**
- `kitchen_dashboard_controller.dart` chỉ lọc đơn "Thành công" hoặc "Đã giao" → **Nếu Firebase chưa seed data thì màn hình trống**
- Thiếu filter theo `MaQuan` — Hiện tại bếp nhìn thấy **tất cả món** của mọi quán trong phòng
- Không có màn hình đăng nhập chủ quán (hardcoded `maQuan`)

**Cần bổ sung:**
- Thêm filter theo `MaQuan` trong `layDonTong()` 
- Cải thiện UI bếp: thêm header thông tin quán, tổng số đơn

---

### 3. `app_admin` – Phân hệ Quản trị viên

**Vấn đề phát hiện:**
- `hub_management_controller.dart` import `package:shared/test/mock_data.dart` và dùng mock data (KHÔNG kết nối Firestore)
- `reconciliation_controller.dart` dùng mock data, hàm `xuatBaoCaoExcel()` là mock (không xuất file thật)
- `hub_management_screen.dart` dùng `hub.diaChi` và `hub.dangHoatDong` — đã có trong `HubModel` ✅

**Cần bổ sung:**
- Nâng cấp `hub_management_controller.dart` → thực sự kết nối Firestore
- Nâng cấp `reconciliation_controller.dart` → kết nối Firestore + xuất Excel thật (package `excel`)
- Cải thiện UI đối soát: thêm filter theo tháng/ngày

---

## Các thay đổi đề xuất

### Component 1 – `shared` (Dùng chung)

#### [MODIFY] [firebase_core.dart](file:///d:/Năm%203/HKIII/CT220H_LTDĐ/GOM%20DON%20PROJECT/gom_don_project/shared/lib/services/firebase_core.dart)
- Thêm xử lý lỗi nếu Firebase chưa có `google-services.json` (graceful fallback)

---

### Component 2 – `app_driver`

#### [MODIFY] [hub_management_controller.dart](file:///d:/Năm%203/HKIII/CT220H_LTDĐ/GOM%20DON%20PROJECT/gom_don_project/app_admin/lib/features/hub_management/hub_management_controller.dart)
- Chuyển từ mock → Firestore thực

#### [MODIFY] [trip_pool_screen.dart](file:///d:/Năm%203/HKIII/CT220H_LTDĐ/GOM%20DON%20PROJECT/gom_don_project/app_driver/lib/src/features/pooling/trip_pool_screen.dart)
- Cải thiện card hiển thị: tên Hub, ngày giao, số thành viên

#### [MODIFY] [verification_screen.dart](file:///d:/Năm%203/HKIII/CT220H_LTDĐ/GOM%20DON%20PROJECT/gom_don_project/app_driver/lib/src/features/delivery/verification_screen.dart)
- Cải thiện UI pin input, trạng thái màu sắc

---

### Component 3 – `app_merchant`

#### [MODIFY] [kitchen_dashboard_controller.dart](file:///d:/Năm%203/HKIII/CT220H_LTDĐ/GOM%20DON%20PROJECT/gom_don_project/app_merchant/lib/features/bulk_order/kitchen_dashboard_controller.dart)
- Thêm filter theo `MaQuan`

#### [MODIFY] [kitchen_dashboard_screen.dart](file:///d:/Năm%203/HKIII/CT220H_LTDĐ/GOM%20DON%20PROJECT/gom_don_project/app_merchant/lib/features/bulk_order/kitchen_dashboard_screen.dart)
- Cải thiện UI: thêm selector quán, thống kê tổng

---

### Component 4 – `app_admin`

#### [MODIFY] [hub_management_controller.dart](file:///d:/Năm%203/HKIII/CT220H_LTDĐ/GOM%20DON%20PROJECT/gom_don_project/app_admin/lib/features/hub_management/hub_management_controller.dart)
- Kết nối Firestore thực, bỏ mock

#### [MODIFY] [reconciliation_controller.dart](file:///d:/Năm%203/HKIII/CT220H_LTDĐ/GOM%20DON%20PROJECT/gom_don_project/app_admin/lib/features/financial_reconciliation/reconciliation_controller.dart)
- Kết nối Firestore, xuất Excel thật với package `excel`

#### [MODIFY] [reconciliation_screen.dart](file:///d:/Năm%203/HKIII/CT220H_LTDĐ/GOM%20DON%20PROJECT/gom_don_project/app_admin/lib/features/financial_reconciliation/reconciliation_screen.dart)
- Thêm filter ngày, cải thiện bảng dữ liệu

---

## Kế hoạch kiểm tra

### Fix lỗi build (Ưu tiên số 1)
1. **Giải pháp A** (đơn giản nhất): Sao chép project sang `C:\Projects\gom_don_project\`
2. **Giải pháp B**: Tạo junction link `mklink /J C:\GomDon "đường dẫn hiện tại"`

### Firebase
- Nếu có file `google-services.json` → đặt vào `android/app/` của mỗi phân hệ
- Nếu chưa → dùng mock data (đã có sẵn `MockDataSeeder`)

### Test từng phân hệ
1. App Admin: Bấm "Nạp data kiểm thử" → kiểm tra Firestore
2. App Driver: Xem danh sách chuyến → Nhận chuyến
3. App Merchant: Xem đơn tổng bếp

---

## Câu hỏi mở
1. Dự án có file `google-services.json` chưa? (để biết Firebase thật hay mock)
2. Có muốn tích hợp màn hình đăng nhập (Firebase Auth) hay dùng hardcode ID?
3. Chức năng xuất Excel có cần chạy thật trên máy hay chỉ mock OK?
