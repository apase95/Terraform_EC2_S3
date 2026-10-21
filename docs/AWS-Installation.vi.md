# Chuẩn bị AWS CLI v2 và Terraform (Linux x86_64)

Phạm vi: cài công cụ, chuẩn bị môi trường; **không triển khai AWS**. Phần 5 của
[Terraform.md](Terraform.md) chỉ chứa mã HCL trong Markdown, chưa có file `.tf`.

## 1. Cài vào tài khoản người dùng, không sudo

Cần Bash, `curl`, `unzip`, `sha256sum`, mạng HTTPS và Linux x86_64 (AWS CLI cần
glibc; không dùng trực tiếp hướng dẫn này cho Alpine/musl). Kiểm tra `command -v
aws terraform` trước; nếu đã có, dùng bản đó hoặc đánh giá nâng cấp riêng, không
ghi đè. Các lệnh dưới đây chạy trong Bash, dừng khi lỗi; có thể cài thành công
một công cụ rồi thất bại ở công cụ còn lại. Terraform ghim bản ổn định 1.13.5
(>= 1.5), không khẳng định đây là bản mới nhất.

```bash
bash <<'BASH'
set -euo pipefail
[[ "$(uname -sm)" == 'Linux x86_64' ]]
for tool in curl unzip sha256sum; do command -v "$tool" >/dev/null; done
for tool in aws terraform; do
  if command -v "$tool" >/dev/null || [[ -e "$HOME/.local/bin/$tool" || -L "$HOME/.local/bin/$tool" ]]; then
    printf 'Dừng: %s đã tồn tại; không ghi đè.\n' "$tool" >&2; exit 1
  fi
done
[[ ! -e "$HOME/.local/aws-cli" && ! -L "$HOME/.local/aws-cli" ]]
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$HOME/.local/bin"
curl --fail --location --proto '=https' --tlsv1.2 --connect-timeout 15 --max-time 300 \
  https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o "$work/aws.zip"
unzip -q "$work/aws.zip" -d "$work"
"$work/aws/install" --install-dir "$HOME/.local/aws-cli" --bin-dir "$HOME/.local/bin"
v=1.13.5
base="https://releases.hashicorp.com/terraform/$v"
for file in "terraform_${v}_linux_amd64.zip" "terraform_${v}_SHA256SUMS"; do
  curl --fail --location --proto '=https' --tlsv1.2 --connect-timeout 15 --max-time 300 \
    "$base/$file" -o "$work/$file"
done
(cd "$work"; sha256sum --check --ignore-missing "terraform_${v}_SHA256SUMS")
unzip -q "$work/terraform_${v}_linux_amd64.zip" terraform -d "$work/tf"
install -m 755 "$work/tf/terraform" "$HOME/.local/bin/terraform"
BASH
export PATH="$HOME/.local/bin:$PATH"
aws --version
terraform version
```

Thêm `export PATH="$HOME/.local/bin:$PATH"` một lần vào `~/.bashrc` hoặc
`~/.zshrc` nếu muốn giữ PATH cho terminal mới. Không chạy toàn bộ khối cài lại
để nâng cấp: nó chủ động từ chối công cụ đã tồn tại.

Nguồn tải là AWS và HashiCorp chính thức. SHA256 đối chiếu Terraform phát hiện
file hỏng/không khớp, **không tương đương xác thực chữ ký**: checksum cùng máy
chủ vẫn phụ thuộc HTTPS và máy chủ đó. Khối tối giản này chưa xác minh chữ ký
PGP của AWS ZIP hay checksum Terraform. Với yêu cầu xác thực publisher, hãy
kiểm tra chữ ký và fingerprint khóa theo hướng dẫn chính thức trước khi chạy:
[AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html),
[HashiCorp verification](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).

## 2. Các giá trị AWS lấy từ đâu?

Ưu tiên **IAM Identity Center (SSO), credentials tạm thời và MFA**. Không dùng
access key của root. Nếu lab buộc phải dùng IAM user:

1. Nhờ quản trị viên cấp IAM user với **least privilege**, chỉ tài nguyên/hành
   động cần cho lab; không gán `AdministratorAccess` cho tiện.
2. AWS Console → IAM → Users → user của bạn → **Security credentials** →
   **Access keys** → **Create access key** → trường hợp sử dụng **CLI**.
3. `AWS_ACCESS_KEY_ID` là ID khóa; `AWS_SECRET_ACCESS_KEY` là secret tương ứng.
   Secret chỉ xem được lúc tạo. Mất secret thì tạo khóa mới, thay thế và vô hiệu
   hóa/xóa khóa cũ. Không gửi khóa vào chat, ảnh chụp, Git hay log.
4. Credentials tạm thời cần thêm `AWS_SESSION_TOKEN` cùng phiên và sẽ hết hạn.

Region do bạn chọn, **không phải secret**, không được sinh từ access key.
`ap-southeast-1` là Singapore. `AWS_DEFAULT_REGION` phục vụ CLI;
`AWS_REGION` và `TF_VAR_aws_region` được đồng bộ vì provider của bài dùng
`var.aws_region`. AZ của bài mặc định Singapore: file đặt
`TF_VAR_availability_zone=ap-southeast-1a`. Nếu đổi region, phải chọn lại AZ
thực sự có sẵn cho tài khoản (không mặc định mọi region đều dùng hậu tố `a`).

## 3. File môi trường riêng

`.env.aws` đã tạo với **credentials trống**; `.env.aws.example` là mẫu chia sẻ.
Nếu chưa có file local, tạo bằng `cp -n .env.aws.example .env.aws`, không ghi đè
file chứa khóa. Từ thư mục gốc dự án:

```bash
chmod 600 .env.aws
# Dùng editor riêng để điền khóa; không gõ secret vào lệnh lưu trong history.
# Chỉ sau khi điền đầy đủ, trong terminal riêng cho lab:
unset AWS_PROFILE AWS_DEFAULT_PROFILE AWS_SESSION_TOKEN AWS_SECURITY_TOKEN
source ./.env.aws
aws --version
terraform version
# Chỉ chạy sau khi đã cấu hình credentials:
aws sts get-caller-identity --no-cli-pager
```

`source` thực thi shell: chỉ source file tin cậy; AWS CLI/Terraform **không tự
đọc dotenv**. Không dùng `cat .env.aws`, `env`, `set -x` hay in secret để kiểm tra.
Lệnh STS chỉ kiểm tra danh tính, không tạo hạ tầng; đầu ra có account/ARN nên
không chia sẻ tùy tiện. Đóng terminal lab để bỏ môi trường tạm. File local bị
ignore nhưng ignore không bảo vệ file đã từng được Git track; nếu lộ khóa phải
thu hồi/rotate ngay. State, plans, `.terraform` cũng bị ignore; giữ lockfile
`.terraform.lock.hcl` khi sau này có dự án Terraform thực tế.

### Thay thế bằng SSO (khuyến nghị)

Không source `.env.aws` với khóa trống khi dùng SSO. Mở terminal sạch hoặc bỏ
credentials môi trường, vì khóa môi trường có thể lấn át profile:

```bash
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_SECURITY_TOKEN
unset AWS_PROFILE AWS_DEFAULT_PROFILE
aws configure sso --profile lab
aws sso login --profile lab
export AWS_PROFILE=lab
export AWS_DEFAULT_REGION=ap-southeast-1
export AWS_REGION="$AWS_DEFAULT_REGION"
export TF_VAR_aws_region="$AWS_DEFAULT_REGION"
export TF_VAR_availability_zone=ap-southeast-1a
aws sts get-caller-identity --no-cli-pager
```

SSO cần Start URL/Issuer URL, SSO region, account và permission set do tổ chức
cấp; SSO region có thể khác region triển khai. Không trộn token cũ, khóa IAM
và profile SSO; đăng nhập lại khi phiên hết hạn.

## 4. Trước khi thực hành phần 5

- Sơ đồ ghi SSH từ “My IP”, nhưng mã HCL hiện mở port 22 cho `0.0.0.0/0`.
  Phải thu hẹp về IP công khai của bạn `/32` hoặc dùng phương án truy cập an
  toàn phù hợp trước khi triển khai; không copy rồi apply nguyên trạng.
- EC2, public IPv4, EBS/storage và S3 có thể phát sinh phí; không mặc định lab
  miễn phí dù instance là `t3.micro`. Kiểm tra giá, quyền và budget trước.
- Khi chủ động làm lab sau này, xem plan kỹ, hủy tài nguyên bằng
  `terraform destroy` trong đúng workspace và kiểm tra tài nguyên còn sót.
  Hướng dẫn onboarding này không chạy `init`, `plan`, `apply` hoặc `destroy`.
