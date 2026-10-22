# Chuẩn bị quyền AWS cho bài lab

Phần này dành cho **quản trị viên (admin)**. Người chạy lab dùng IAM user có sẵn `nooby_handsome_OperatorUser` trong tài khoản `565856126571`, không dùng root hoặc khóa admin.

## 1. Admin rà soát user

Đăng nhập bằng phiên admin riêng, vào **IAM → Users → nooby_handsome_OperatorUser → Permissions**. Gỡ các policy rộng gắn trực tiếp/inline và bỏ user khỏi nhóm cấp quyền rộng. Quyền Allow được cộng dồn: gắn policy lab không tự thu hồi quyền đã có.

Không gắn `AdministratorAccess`, `AmazonEC2FullAccess` hoặc `AmazonS3FullAccess` để bỏ qua lỗi. Giữ cơ chế đăng nhập an toàn, bật MFA khi phù hợp.

## 2. Tạo hoặc cập nhật policy lab

1. Mở [file policy mẫu](../iam/terraform-lab-policy.json).
2. Trong **IAM → Policies**, tạo customer managed policy bằng tab **JSON** và dán nội dung file. Nếu đã có policy lab, chọn chỉnh sửa policy đó.
3. **Trước khi lưu**, tìm statement có Sid `PrivateAssets` và thêm vào danh sách `Action`:
   - `s3:GetObjectTagging`
   - `s3:PutObjectTagging`
4. Giữ nguyên các quyền còn lại, phạm vi bucket/object, region và điều kiện. Kiểm tra cảnh báo JSON rồi lưu với tên `TerraformLabSingaporeDev`; nếu chỉnh sửa, đặt phiên bản vừa lưu làm mặc định.

**File mẫu trong repository hiện thiếu hai quyền trên.** Terraform cần chúng để đọc/ghi tag của object; lần apply trước đã gặp lỗi thiếu `s3:GetObjectTagging`. Bổ sung ở policy trên AWS là bước bắt buộc trước khi chạy; không giả định file mẫu đã đủ hoặc policy từ xa đã được sửa.

## 3. Gắn policy và cấp khóa cho operator

1. Vào **Users → nooby_handsome_OperatorUser → Add permissions → Attach policies directly**, chọn policy lab rồi xác nhận. Nếu policy đã gắn, kiểm tra đúng policy và phiên bản mặc định.
2. Admin tạo access key cho chính user operator tại **Security credentials → Access keys → Create access key**, chọn trường hợp CLI phù hợp. Lab không có quyền IAM để tự tạo khóa.
3. Chuyển khóa qua kênh an toàn để người vận hành nhập vào file riêng trên máy. Secret chỉ hiện lúc tạo; không gửi vào chat, tài liệu, ảnh chụp hoặc Git. Không cấp khóa root/admin cho lab.
4. Người vận hành tiếp tục [chuẩn bị công cụ và kiểm tra danh tính](AWS-Installation.vi.md), rồi mới [chạy demo](../terraform/README.md).

## 4. Phạm vi và cách xử lý lỗi

- Cấu hình hiện tại khóa Singapore `ap-southeast-1`, môi trường `dev`, máy `t3.micro` và bucket `demo-web-assets-565856126571-dev`. Nếu tên bucket đã bị chiếm, dừng để admin rà soát đồng thời policy và giới hạn cấu hình; không đổi tên tùy tiện.
- S3 giữ mặc định riêng tư, không cấp website public hay ACL public. EC2 không có IAM role để đọc S3; website và ảnh mẫu hoạt động độc lập. Không cần mở SSH.
- `iam:ListPolicies` bị từ chối là **dự kiến**, không phải bằng chứng gắn sai policy. Lab không được duyệt/quản lý IAM; admin kiểm tra việc gắn policy từ phiên riêng.
- Không có quyền liệt kê tất cả bucket. Dùng đúng tên bucket trong hướng dẫn chạy, thay vì yêu cầu mở rộng quyền để duyệt Console.
- Với lỗi AccessDenied khác, gửi admin tên action/resource và thông báo đã che thông tin nhạy cảm. Admin rà soát quyền cụ thể, không thay bằng full access. Hướng dẫn này không chứng nhận policy đã được kiểm thử runtime với AWS provider `~> 5.0`.

## 5. Giới hạn an toàn và chi phí

Đây là policy thu hẹp phạm vi, **không phải ranh giới least privilege tuyệt đối** hay permissions boundary. Các quyền mạng và tagging vẫn có thể ảnh hưởng tài nguyên khác của tài khoản trong Singapore. Tag `dev` không ngăn người có quyền sửa tag; policy ảnh máy cũng không tự ép chủ sở hữu Canonical dù cấu hình hiện tại có lọc.

Giới hạn loại máy không giới hạn số lượng máy, dung lượng EBS/S3 hoặc tổng chi phí. EC2, EBS, IPv4 công khai và truyền dữ liệu có thể tính phí; budget chỉ cảnh báo, không chặn hóa đơn. Sau demo, dọn bằng Terraform và kiểm tra tài nguyên còn sót, kể cả khi apply lỗi. Không xóa state để dọn tài nguyên.
