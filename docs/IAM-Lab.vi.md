# IAM cho bài lab Terraform

Policy khởi điểm: [`iam/terraform-lab-policy.json`](../iam/terraform-lab-policy.json), tài khoản `565856126571`, Singapore `ap-southeast-1`, AWS provider `~> 5.0`; dành cho mục 5 của [Terraform.md](Terraform.md).

## Admin gắn policy cho IAM user hiện có

1. Dùng phiên **admin riêng**, không dùng user lab để tự cấp quyền. Xác nhận đúng tài khoản và user.
2. Trong **IAM → Users → user → Permissions**, rà soát và gỡ các policy rộng khác (managed/inline), đồng thời bỏ user khỏi các group cấp quyền rộng trước khi gắn policy này. Quyền Allow cộng dồn; policy này không phải permissions boundary hay explicit Deny. Giữ nguyên cơ chế đăng nhập an toàn; không chia sẻ access key.
3. **IAM → Policies → Create policy → JSON**: dán toàn bộ file JSON, kiểm tra cảnh báo, đặt tên `TerraformLabSingaporeDev`, rồi **Create policy**.
4. **Users → user → Add permissions → Attach policies directly**: chọn policy vừa tạo, kiểm tra rồi **Add permissions**. Không gắn `AdministratorAccess`, `AmazonEC2FullAccess` hoặc `AmazonS3FullAccess`.

Các bước trên do admin thực hiện thủ công; không có quyền IAM trong policy lab. Chưa gắn policy hay gọi AWS trong lần soạn này.

## Điều chỉnh HCL trước khi dùng

- Giữ region `ap-southeast-1`, instance `t3.micro`, tag `Environment = "dev"` (phân biệt hoa/thường). Quyền launch instance có điều kiện loại máy và tag; quyền AMI/subnet/SG/volume/network interface được tách riêng để tránh lỗi xác thực đa tài nguyên. Terminate dùng tag dev, không dùng điều kiện loại máy.
- Đổi ví dụ bucket có hậu tố ngày thành `bucket = "demo-web-assets-565856126571-dev"`. Nếu tên đã bị chiếm, admin phải đồng thời sửa policy và HCL sang tên khác; không mở rộng thành mọi bucket.
- Bucket mới giữ mặc định AWS **private**, Block Public Access và Object Ownership; dùng **S3 Standard** cho ít ảnh/assets. Không cấu hình ACL public, bucket policy hay website hosting: policy không cho ghi các cấu hình này. Object private không tự trở thành ảnh public cho website; EC2 cũng không tự có quyền S3 (không có instance role/PassRole trong lab).
- Dùng Terraform trực tiếp với tên bucket đã biết; không cấp `s3:ListAllMyBuckets` để duyệt S3 Console. Xóa hết object trước `terraform destroy`; không bật versioning trong lab này.
- Giới hạn SSH về IP cá nhân thay vì `0.0.0.0/0` trong ví dụ.

## Giới hạn quan trọng

Đây là policy giới hạn action/region và ARN tài khoản cho mutation EC2, **không phải mức tối thiểu chính xác đã được kiểm chứng với provider thật**. Read EC2 dùng `Resource: "*"` vì các Describe API cần phạm vi đó. Network lifecycle và tagging vẫn có thể tác động tài nguyên khác trong tài khoản/region, kể cả đổi tag instance; tag dev không phải ranh giới bảo mật chống user cố ý sửa tag. AMI ARN không chứa account owner: HCL lọc Canonical `099720109477`, nhưng policy cho phép image ARN trong region, không tự ép owner Canonical. Không cấp sửa instance tùy ý; thay đổi cấu hình ngoài ví dụ có thể cần admin review thêm quyền cụ thể.

S3 chỉ đúng bucket/object nói trên, có read cấu hình phục vụ refresh `aws_s3_bucket` v5 và quyền tạo/xóa/tag/object cơ bản; không blanket full access. Các API refresh thực tế có thể thay đổi theo bản provider; nếu AccessDenied, admin cần review action/resource cụ thể, không thay bằng wildcard.

IAM chỉ giới hạn **loại** instance khi launch, không giới hạn **số lượng**, dung lượng EBS/S3 hoặc tổng hóa đơn. EC2, EBS, public IPv4, truyền dữ liệu và S3 có thể tính phí; không đảm bảo miễn phí hay hard spending cap. Theo dõi Billing/Budgets (cảnh báo không phải chặn chi phí), dọn tài nguyên sau lab. Không đưa credentials hoặc state chứa bí mật vào repository.
