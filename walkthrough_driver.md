# 🚗 Walkthrough: Hoàn Thành Nghiệp Vụ Driver (Phân Hệ Tài Xế)

> Dự án: **GomĐơn** — Flutter + Firebase | Vai trò: **Thành viên B** (app_driver)

---

## 🛠️ Các thay đổi đã thực hiện

Chúng tôi đã thay thế toàn bộ dữ liệu mock cục bộ (`mock_data.dart`) bằng logic giao tiếp thời gian thực kết nối trực tiếp đến **Firebase Firestore** thông qua các lớp dùng chung từ thư viện [shared](file:///d:/N%C4%83m%203/HKIII/CT220H_L%E1%BA%ADp%20tr%C3%ACnh%20n%E1%BB%81n%20t%E1%BA%A3ng%20%C4%91a%20di%20%C4%91%E1%BB%99ng/GOM%20DON%20PROJECT/gom_don_project/shared):

### 1. Phân hệ Nhận chuyến (Trip Pooling)
* **File cập nhật**: [trip_pool_controller.dart](file:///d:/N%C4%83m%203/HKIII/CT220H_L%E1%BA%ADp%20tr%C3%ACnh%20n%E1%BB%81n%20t%E1%BA%A3ng%20%C4%91a%20di%20%C4%91%E1%BB%99ng/GOM%20DON%20PROJECT/gom_don_project/app_driver/lib/src/features/pooling/trip_pool_controller.dart)
  * Lấy các phòng từ collection `rooms` có trạng thái `"Thành công"` và chưa có tài xế nhận (`MaTaiXe` là `null`).
  * Thực hiện **Transaction Firestore** để khóa chuyến xe ngay lập tức khi tài xế bấm nút "Nhận chuyến", đảm bảo chống tranh chấp giữa nhiều tài xế.
  * Cập nhật đồng bộ thông tin tài xế (`MaTaiXe`, `TenTaiXe`) vào tất cả các đơn hàng con thuộc phòng đó trong collection `orders`.
* **File cập nhật**: [trip_pool_screen.dart](file:///d:/N%C4%83m%203/HKIII/CT220H_L%E1%BA%ADp%20tr%C3%ACnh%20n%E1%BB%81n%20t%E1%BA%A3ng%20%C4%91a%20di%20%C4%91%E1%BB%99ng/GOM%20DON%20PROJECT/gom_don_project/app_driver/lib/src/features/pooling/trip_pool_screen.dart)
  * Thiết kế lại giao diện dạng danh sách thẻ (card layout) chuyên nghiệp, hiển thị số Hub, Ngày giao, tổng số lượng món ăn và số lượng khách.
  * Thêm hộp thoại hỏi tài xế "Có muốn đi giao hàng ngay không" để chuyển hướng nhanh sang màn hình Xác nhận giao hàng sau khi nhận chuyến thành công.

### 2. Phân hệ Xác thực giao hàng (Verification / Delivery)
* **File cập nhật**: [verification_controller.dart](file:///d:/N%C4%83m%203/HKIII/CT220H_L%E1%BA%ADp%20tr%C3%ACnh%20n%E1%BB%81n%20t%E1%BA%A3ng%20%C4%91a%20di%20%C4%91%E1%BB%99ng/GOM%20DON%20PROJECT/gom_don_project/app_driver/lib/src/features/delivery/verification_controller.dart)
  * Truy vấn danh sách đơn hàng con theo mã phòng từ collection `orders`.
  * Cập nhật trường `TrangThaiDonHang` thành `"Đã giao"` trên Firestore khi khớp mã PIN hoặc quét mã QR.
* **File cập nhật**: [verification_screen.dart](file:///d:/N%C4%83m%203/HKIII/CT220H_L%E1%BA%ADp%20tr%C3%ACnh%20n%E1%BB%81n%20t%E1%BA%A3ng%20%C4%91a%20di%20%C4%91%E1%BB%99ng/GOM%20DON%20PROJECT/gom_don_project/app_driver/lib/src/features/delivery/verification_screen.dart)
  * Hỗ trợ 2 chế độ:
    1. **Chỉ định phòng cụ thể**: Giao diện chi tiết các đơn cần giao của phòng vừa nhận.
    2. **Danh sách chuyến của tôi**: Nếu vào từ màn hình chính, hệ thống tự động tìm và hiển thị tất cả các mã phòng mà tài xế này (`DRIVER_TEST`) đã nhận.
  * Tích hợp chức năng nhập mã PIN 4 chữ số của khách.
  * Tích hợp hộp thoại **Mô phỏng quét mã QR** (cho phép nhập mã PIN hoặc mã đơn hàng của khách hàng) để hoàn thành giao hàng ngay cả trên máy ảo không có camera.

### 3. Điều hướng màn hình chính
* **File cập nhật**: [main.dart](file:///d:/N%C4%83m%203/HKIII/CT220H_L%E1%BA%ADp%20tr%C3%ACnh%20n%E1%BB%81n%20t%E1%BA%A3ng%20%C4%91a%20di%20%C4%91%E1%BB%99ng/GOM%20DON%20PROJECT/gom_don_project/app_driver/lib/main.dart)
  * Loại bỏ các placeholder trống.
  * Thiết kế lại giao diện trang chủ kênh Tài xế sang màu chủ đạo Xanh Dương cá tính với nền chuyển sắc (gradient).
  * Liên kết trực tiếp hai nút bấm chính tới hai luồng nghiệp vụ trên.

---

## 🚀 Hướng dẫn Quy trình Kiểm thử (Nghiệm thu)

Hãy sử dụng song song hai ứng dụng `app_admin` và `app_driver` để chạy luồng kiểm thử:

### Bước 1: Nạp Dữ Liệu Kiểm Thử (từ Admin)
1. Chạy ứng dụng [app_admin](file:///d:/N%C4%83m%203/HKIII/CT220H_L%E1%BA%ADp%20tr%C3%ACnh%20n%E1%BB%81n%20t%E1%BA%A3ng%20%C4%91a%20di%20%C4%91%E1%BB%99ng/GOM%20DON%20PROJECT/gom_don_project/app_admin).
2. Tại màn hình chính, bấm nút màu đỏ **NẠP DATA KIỂM THỬ (DEV B)**. 
3. Kiểm tra trên Firebase Console để đảm bảo collection `rooms` và `orders` đã có dữ liệu ảo của `ROOM_001` (Trạng thái: *Thành công*, *MaTaiXe*: `null`).

### Bước 2: Nhận Chuyến (trên Driver App)
1. Chạy ứng dụng [app_driver](file:///d:/N%C4%83m%203/HKIII/CT220H_L%E1%BA%ADp%20tr%C3%ACnh%20n%E1%BB%81n%20t%E1%BA%A3ng%20%C4%91a%20di%20%C4%91%E1%BB%99ng/GOM%20DON%20PROJECT/gom_don_project/app_driver).
2. Vào **Danh sách chuyến xe (Chờ nhận)**. Bạn sẽ thấy thẻ phòng `ROOM_001`.
3. Bấm **Nhận Chuyến Xe Này** → Xác nhận.
4. Một thông báo SnackBar màu xanh lá hiện lên: `Đã nhận chuyến ROOM_001 thành công!`.
5. Bấm **Giao ngay** trên hộp thoại pop-up tiếp theo để nhảy thẳng tới màn hình giao hàng.

### Bước 3: Xác thực Giao hàng & Đổi trạng thái Firestore
1. Tại màn hình giao hàng của `ROOM_001`, bạn sẽ thấy 2 đơn hàng:
   * Khách hàng **Nguyễn Văn A** (Đơn `ORD_1001`, mã PIN đúng là `1234`).
   * Khách hàng **Trần Thị B** (Đơn `ORD_1002`, mã PIN đúng là `5678`).
2. **Kiểm thử nhập mã PIN**:
   * Nhập mã PIN sai (ví dụ `0000`) và bấm **Nhập PIN** → SnackBar báo đỏ và không cho giao.
   * Nhập mã PIN đúng `1234` và bấm **Nhập PIN** → SnackBar báo xanh, giao diện đổi màu xanh lá và hiển thị huy hiệu `Đã giao`.
3. **Kiểm thử quét mã QR**:
   * Đối với đơn của Trần Thị B, bấm nút **Quét mã QR của khách**.
   * Nhập mã PIN `5678` (hoặc mã đơn `ORD_1002`) vào ô pop-up để mô phỏng hành động quét → Xác nhận thành công và cập nhật trạng thái `"Đã giao"`.
4. Mở Firebase Console: Xác nhận trạng thái của `orders/ORD_1001` và `orders/ORD_1002` đã được tự động cập nhật thành `'Đã giao'`.
