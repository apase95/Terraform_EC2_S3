# Demo Terraform: website nhỏ trên AWS

Tạo một website thử nghiệm bằng Terraform — công cụ đọc cấu hình trong dự án để tạo và dọn tài nguyên AWS, thay vì thao tác từng mục bằng tay.

## Bạn sẽ có gì?

- Một máy chủ Ubuntu 22.04 (`t3.micro`) tự cài Nginx, hiển thị lời chào tiếng Anh qua HTTP.
- Một mạng riêng cho bài lab, có đường kết nối Internet và chỉ mở cổng web 80; **không mở SSH**.
- Một kho S3 **riêng tư** chứa ảnh mẫu `assets/demo.svg`. Website chạy trên EC2 độc lập, không lấy ảnh từ S3.

Bài lab dành cho tài khoản `565856126571`, vùng Singapore (`ap-southeast-1`), môi trường `dev`. Đây là demo học tập, không phải website production có HTTPS.

## Bắt đầu từ đâu?

| Thứ tự | Tài liệu | Nội dung |
| --- | --- | --- |
| 1 | [Hiểu mini project](docs/Terraform.md) | Thành phần, cách kết nối và kết quả mong đợi |
| 2 | [Chuẩn bị quyền AWS](docs/IAM-Lab.vi.md) | Các bước quản trị viên cần làm trước |
| 3 | [Cài công cụ và cấu hình đăng nhập](docs/AWS-Installation.vi.md) | Chuẩn bị máy và kiểm tra đúng tài khoản |
| 4 | [Chạy và dọn demo](terraform/README.md) | Các lệnh thực hành khi bạn sẵn sàng |

## Lưu ý trước khi chạy

**Có thể phát sinh phí:** EC2, ổ EBS, địa chỉ IPv4 công khai, S3 và truyền dữ liệu không tự động miễn phí. Budget là cảnh báo, không phải trần chi tiêu.

Sau demo, dọn bằng Terraform và kiểm tra tài nguyên còn sót. Lần triển khai thất bại vẫn có thể để lại tài nguyên tính phí; **không xóa state để dọn hạ tầng**. Không đưa khóa AWS, state hoặc plan vào Git hay chat.
