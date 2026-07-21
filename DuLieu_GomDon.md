# Dữ Liệu Mẫu Hệ Thống GomĐơn (Mock Data)

Dưới đây là cấu trúc dữ liệu mẫu (mock data) cho các vai trò trong hệ thống GomĐơn, sẵn sàng để import vào Firebase Firestore. 

*Lưu ý: Mật khẩu chung cho tất cả các tài khoản là `123456` (Trong thực tế, mật khẩu này sẽ được Firebase Authentication xử lý và mã hóa, Firestore chỉ lưu trữ thông tin hồ sơ bên dưới).*

## 1. Collection: `users` (Khách hàng)

| Document ID (UID) | TenKhachHang | SoDienThoai | SoDuVi (VNĐ) | TrangThaiVi |
| :--- | :--- | :--- | :--- | :--- |
| `user_001` | Nguyễn Văn An | 0901234567 | 150000 | Hoạt động |
| `user_002` | Trần Thị Bích | 0912345678 | 50000 | Hoạt động |
| `user_003` | Lê Hoàng Cường | 0923456789 | 0 | Tạm khóa |

## 2. Collection: `merchants` (Quán ăn)

| Document ID (UID) | TenQuan | DanhSachMon | TrangThai |
| :--- | :--- | :--- | :--- |
| `merchant_001` | Cơm Tấm Bà Ba | `["Cơm sườn", "Cơm bì chả", "Trà đá"]` | Mở cửa |
| `merchant_002` | Trà Sữa Toocha | `["Trà sữa trân châu", "Hồng trà", "Lục trà"]` | Mở cửa |
| `merchant_003` | Bún Bò Huế O Mập | `["Bún bò tái", "Bún bò giò heo", "Sữa đậu"]`| Đóng cửa |

## 3. Collection: `drivers` (Tài xế)

| Document ID (MaTaiXe) | TenTaiXe | SoDienThoai | BienSoXe | TrangThaiHoatDong |
| :--- | :--- | :--- | :--- | :--- |
| `DRIVER_TEST` | Phạm Văn Dũng | 0934567890 | 65B1-123.45 | Sẵn sàng |
| `driver_002` | Đinh Trọng Em | 0945678901 | 65C1-543.21 | Đang giao |
| `driver_003` | Vũ Thị Hoa | 0956789012 | 65A1-999.99 | Ngoại tuyến |

## 4. Collection: `admins` (Quản trị viên)

| Document ID (UID) | HoTen | Email | PhanQuyen (Role) | TrangThai |
| :--- | :--- | :--- | :--- | :--- |
| `admin_001` | Hệ thống (Super Admin) | admin@gomdon.vn | Toàn quyền | Kích hoạt |
