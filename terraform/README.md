# Demo Terraform AWS (Singapore/dev)

VPC riêng, public subnet, Ubuntu 22.04/t3.micro chạy Nginx (chỉ HTTP 80,
không SSH), EBS gp3 8 GiB mã hóa và S3 private có `assets/demo.svg`.
EC2 không có instance profile nên **không thể tải object private từ S3**;
trang Nginx độc lập, không nhúng asset đó. Không tạo IAM hay cấu hình S3 public.

## Chạy thủ công từ thư mục gốc dự án

Nếu chưa có access key: nhờ admin tạo key cho `nooby_handsome_OperatorUser`
(IAM → Users → Security credentials → Create access key). Nhập credentials
trực tiếp vào `.env.aws` trên máy, **không gửi vào chat**, không xin quyền IAM
tự cấp. `iam:ListPolicies` bị từ chối là dự kiến, không cần thêm quyền này.

```bash
export PATH="$HOME/.local/bin:$PATH"
# Chỉ sau khi đã điền credentials cục bộ; source một lần trong shell này:
set -a
source .env.aws
set +a
aws sts get-caller-identity
```

**Dừng nếu** Account không phải `565856126571` hoặc Arn không phải user
`nooby_handsome_OperatorUser`. Provider cũng chặn sai account; biến giới hạn
Singapore, dev, t3.micro và đúng bucket trong policy. AZ mặc định
`ap-southeast-1a` phải khả dụng trong account.

```bash
terraform -chdir=terraform init -backend=false
terraform -chdir=terraform fmt -check
terraform -chdir=terraform validate
terraform -chdir=terraform plan -out=demo.tfplan
```

Review plan và chi phí trước. **Chỉ khi bạn chủ động quyết định triển khai**,
chạy lệnh dưới (saved plan apply không hỏi xác nhận lại):

```bash
terraform -chdir=terraform apply demo.tfplan
# Đợi vài phút để cloud-init cài Nginx rồi kiểm tra; thử lại nếu chưa sẵn sàng:
curl --fail "$(terraform -chdir=terraform output -raw web_url)"
# Tùy chọn: tải asset private bằng credentials operator, không phải EC2:
aws s3 cp s3://demo-web-assets-565856126571-dev/assets/demo.svg /tmp/demo.svg --region ap-southeast-1
```

## Dọn dẹp và giới hạn

```bash
terraform -chdir=terraform destroy
```

Review rồi xác nhận xóa. Terraform xóa object demo do nó quản lý; bucket dùng
`force_destroy=false`, vì vậy object ngoài Terraform sẽ chặn xóa bucket.
Tự kiểm tra/xóa các object thêm vào trước khi thử lại, không xóa dữ liệu lạ.
Không tái sử dụng saved plan cũ sau apply/destroy; tạo plan mới.

EC2, EBS, public IPv4, S3 và truyền dữ liệu có thể tính phí; không đảm bảo
free tier hay giới hạn hóa đơn. Kiểm tra tài nguyên đã dọn trong console.
Giữ state cục bộ an toàn để còn destroy; không commit credentials/state/plan.
Cache `.terraform/` và `demo.tfplan` đã được ignore; giữ `.terraform.lock.hcl`.

Kiểm tra local (`fmt`, `init`, `validate`) không chứng minh IAM/runtime hoạt
động. Chưa triển khai hay kiểm tra tích hợp AWS. Nếu AccessDenied khi chạy thật,
nhờ admin review action/resource cụ thể, không mở rộng policy tùy tiện.
