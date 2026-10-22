# Mini project: website Nginx và kho S3 riêng tư trên AWS

## Mục tiêu và kết quả

Bài thực hành giúp bạn tạo một website nhỏ từ cấu hình Terraform có sẵn trong thư mục terraform. Bạn sẽ hiểu cách mạng, máy chủ và kho lưu trữ được tạo cùng nhau, rồi dọn chúng sau khi học xong.

Sau khi triển khai thành công và Nginx khởi động xong, bạn có thể mở địa chỉ web được trả về để thấy lời chào “Hello from Terraform + Nginx!”. Một ảnh mẫu assets/demo.svg được lưu riêng trong S3, không xuất hiện trên website.

Lab khóa tài khoản AWS 565856126571, vùng Singapore (ap-southeast-1), môi trường dev và loại máy t3.micro. Vùng đặt máy mặc định là ap-southeast-1a; cần bảo đảm vùng này khả dụng trong tài khoản.

## Các thành phần

Terraform quản lý 9 tài nguyên trong demo:

| Thành phần | Vai trò dễ hiểu |
| --- | --- |
| VPC | Mạng riêng của bài lab, dải địa chỉ 10.0.0.0/16 |
| Public subnet | Một phần mạng đặt máy chủ, dải 10.0.1.0/24 |
| Internet Gateway | Cổng nối mạng của lab với Internet |
| Route table | Bảng chỉ đường ra Internet qua cổng trên |
| Route table association | Gắn bảng chỉ đường vào subnet |
| Security Group | Tường lửa cho máy chủ: chỉ nhận HTTP cổng 80, cho phép kết nối ra ngoài |
| EC2 | Máy Ubuntu 22.04 chạy Nginx, loại t3.micro, có IPv4 công khai |
| S3 bucket | Kho riêng tư có tên demo-web-assets-565856126571-dev |
| S3 object | Ảnh mẫu assets/demo.svg nằm trong kho đó |

Máy EC2 có ổ EBS gp3 8 GiB được mã hóa; ổ này được cấu hình cùng máy, không phải tài nguyên Terraform riêng trong con số 9 trên. Terraform tra cứu ảnh hệ điều hành Ubuntu của Canonical thay vì tự tạo ảnh mới.

## Website và S3 hoạt động thế nào?

- Người xem mở địa chỉ HTTP công khai của EC2. Kết nối đi qua cổng Internet và mạng của lab, được tường lửa cho phép ở cổng 80, rồi Nginx trả trang web.
- Khi máy khởi động lần đầu, cấu hình tự động cài Nginx và tạo trang chào. Máy cần kết nối ra Internet để tải gói cài đặt; việc này có thể mất vài phút.
- S3 chỉ lưu ảnh mẫu riêng tư. Người vận hành có quyền có thể tải ảnh bằng AWS CLI theo hướng dẫn chạy demo.
- EC2 không có IAM role, nên không được cấp quyền đọc S3. Trang web không nhúng ảnh từ bucket; địa chỉ S3 trả về không phải liên kết ảnh công khai.

Demo không mở SSH, không có HTTPS, NAT Gateway hay S3 public website. Không dùng nó để gửi dữ liệu nhạy cảm hoặc làm hệ thống production.

## Terraform biết thứ tự tạo ra sao?

Cấu hình tham chiếu các thành phần liên quan: subnet cần VPC; bảng chỉ đường cần cổng Internet; EC2 cần subnet và tường lửa. EC2 còn chờ việc gắn bảng chỉ đường hoàn tất để có đường tải Nginx. Ảnh S3 cần bucket tồn tại trước.

Terraform dựa vào các quan hệ này để sắp thứ tự, thay vì yêu cầu bạn tự tạo từng thành phần. S3 là nhánh riêng, không phải bước kết nối website với kho ảnh.

## Trình tự thực hành

1. **Chuẩn bị quyền:** nhờ admin làm theo [hướng dẫn IAM](IAM-Lab.vi.md), bao gồm bổ sung hai quyền object tagging còn thiếu trong policy mẫu.
2. **Chuẩn bị máy:** làm theo [hướng dẫn cài công cụ và đăng nhập](AWS-Installation.vi.md). Kiểm tra đúng user và tài khoản trước khi tiếp tục.
3. **Khởi tạo (init):** tải thành phần giúp Terraform giao tiếp với AWS, rồi kiểm tra cấu hình.
4. **Xem kế hoạch (plan):** đọc những gì sẽ tạo, sửa hoặc xóa; kiểm tra phạm vi và chi phí trước khi đồng ý. Plan thành công không bảo đảm triển khai sẽ thành công.
5. **Triển khai (apply):** chỉ thực hiện khi bạn chủ động quyết định tạo tài nguyên thật. Kế hoạch đã lưu được áp dụng mà không hỏi xác nhận lại.
6. **Kiểm tra:** đợi Nginx sẵn sàng rồi mở địa chỉ web được trả về. Nếu muốn, tải ảnh S3 bằng quyền operator, không phải từ EC2.
7. **Dọn dẹp (destroy):** xem danh sách xóa, xác nhận và kiểm tra lại trên AWS sau demo.

Các lệnh cụ thể nằm trong [hướng dẫn chạy demo](../terraform/README.md); tài liệu này chỉ giải thích mini project, không thay thế hướng dẫn đó.

## Chi phí và dọn dẹp an toàn

EC2, EBS, IPv4 công khai, S3 và truyền dữ liệu có thể tính phí; máy nhỏ không đồng nghĩa miễn phí. Theo dõi Billing/Budgets, nhưng đừng coi cảnh báo budget là giới hạn hóa đơn.

Nếu triển khai lỗi giữa chừng, một số tài nguyên vẫn có thể đã được tạo. Giữ file state an toàn: đây là bản ghi giúp Terraform tìm đúng tài nguyên để quản lý và xóa. Không xóa state để “làm sạch”, không đưa state, plan hay khóa AWS lên Git.

Terraform sẽ xóa ảnh demo do nó quản lý. Nếu bạn tự thêm object khác, bucket sẽ từ chối bị xóa cho đến khi chúng được xử lý; kiểm tra dữ liệu trước, không xóa dữ liệu lạ. Sau khi dọn, kiểm tra tài nguyên còn sót và không dùng lại plan cũ.
