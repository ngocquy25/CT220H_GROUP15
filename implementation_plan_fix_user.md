# Kế hoạch: Nạp dữ liệu & Sửa lỗi GPS + Đặt hàng

## Mô tả
Firestore hiện đang trống hoàn toàn → app_user không đăng nhập được, không hiển thị hub,
không đặt hàng được. Kế hoạch này sẽ seed đầy đủ dữ liệu + cấu hình indexes + sửa GPS.

---

## Phần 1 — Seed Data vào Firestore

Tạo file `lib/main_seed.dart` — chạy một lần bằng lệnh:
```
flutter run -t lib/main_seed.dart
```

### Collections sẽ được tạo:

| Collection | Số documents | Nội dung |
|---|---|---|
| `hubs` | 3 | HUB001, HUB002, HUB003 tại Cần Thơ (bán kính 50.000m để test) |
| `users` | 4 | KH001–KH004, có ví connected, đủ số dư |
| `merchants` | 3 | QA001–QA003, đủ thực đơn 4 món/quán |
| `orders` | 5 | Đủ 4 trạng thái: Chờ chốt, Thành công, Đã giao, Đã hủy |

> **Lưu ý tài khoản test:**
> - SDT: `0901234567` / Mật khẩu: `123456` → KH001 (ví 500.000đ ✅)
> - SDT: `0912345678` / Mật khẩu: `123456` → KH002 (ví 320.000đ ✅)
> - SDT: `0923456789` / Mật khẩu: `123456` → KH003 (ví 800.000đ ✅)
> - SDT: `0934567890` / Mật khẩu: `123456` → KH004 (ví chưa kết nối ❌ — để test trường hợp lỗi)

---

## Phần 2 — Firestore Composite Indexes

Tạo file `firestore.indexes.json` tại gốc project và deploy:

```
firebase deploy --only firestore:indexes --project gom-don-project
```

Indexes cần tạo:
- `rooms`: `MaHubGoc ASC` + `NgayGiao ASC`
- `rooms`: `MaHubGoc ASC` + `NgayGiao ASC` + `TrangThaiPhong ASC`
- `users`: `SoDienThoai ASC` + `MatKhau ASC`
- `orders`: `MaKhachHang ASC` + `ThoiGianDat DESC` (cho màn hình lịch sử)
- `orders`: `MaPhong ASC` (cho màn hình phòng)

---

## Phần 3 — Sửa lỗi GPS trên Emulator

Máy ảo Android mặc định GPS về vị trí **Mountain View, California** (cách Cần Thơ 13.000km).

**Giải pháp A — Hub bán kính 50km (áp dụng trong seed data):**
Đặt `BanKinhMacDinh = 50000` (mét) cho tất cả hub → hub xuất hiện dù GPS ở đâu.

**Giải pháp B — Đặt GPS emulator về Cần Thơ:**
1. Click **...** (Extended Controls) trên emulator sidebar
2. Tab **Location**
3. Nhập: **Latitude: 10.0341**, **Longitude: 105.7469**
4. Click **Set Location**

---

## Proposed Changes

### [NEW] lib/main_seed.dart
Script seeder nạp toàn bộ dữ liệu lên Firestore một lần.

### [NEW] firestore.indexes.json
Cấu hình composite indexes cho các query phức tạp.

---

## Verification Plan

### Sau khi seed:
1. Đăng nhập bằng SDT `0901234567` / pass `123456`
2. Chọn Hub → danh sách 3 hub xuất hiện
3. Vào trang Home → thấy phòng gom đơn
4. Chọn quán → chọn món → đặt hàng → thành công
5. Kiểm tra lịch sử đơn → thấy đủ 5 trạng thái

### Test các trường hợp lỗi:
- Login sai mật khẩu → thông báo lỗi
- Ví không kết nối (KH004) → thông báo lỗi
- Số dư không đủ → thông báo lỗi
