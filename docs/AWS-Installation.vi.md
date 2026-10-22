# Chuẩn bị máy để chạy demo AWS

Làm lần lượt các bước dưới đây. Đây chỉ là hướng dẫn chuẩn bị; **không tự cài công cụ hay triển khai AWS**. Cấu hình chạy được đã có trong [thư mục terraform](../terraform/README.md).

## 1. Kiểm tra máy và công cụ đã có

Hướng dẫn dành cho Linux x86_64 dùng glibc, với Bash hoặc Zsh. Không dùng gói này cho Alpine/musl, ARM, macOS hay Windows; các máy đó xem [AWS CLI chính thức](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) và [Terraform chính thức](https://developer.hashicorp.com/terraform/install).

Chạy trong terminal:

```bash
uname -sm
command -v aws
command -v terraform
```

Nếu có công cụ, kiểm tra riêng bằng `aws --version` và `terraform version`. Môi trường được ghi nhận có AWS CLI **2.38.4**; hãy kiểm tra lại trên máy bạn. Terraform của bài hướng dẫn ghim **1.13.5**, đáp ứng yêu cầu dự án từ 1.5 trở lên, không có nghĩa đây là bản mới nhất.

**Không ghi đè bản đã có.** Nếu thiếu công cụ, cài riêng công cụ đó theo bước sau.

## 2. Cài công cụ còn thiếu, không cần sudo

Cần `curl`, `unzip`, `sha256sum` và kết nối HTTPS. Dùng thư mục tạm mới cho mỗi lần tải.

### AWS CLI v2

Theo [các bước cài Linux chính thức](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html): tải ZIP Linux x86_64 từ AWS vào thư mục tạm, xác minh gói theo hướng dẫn rồi giải nén. Khi chạy bộ cài vừa giải nén, chọn thư mục trong tài khoản người dùng:

```bash
./aws/install --install-dir "$HOME/.local/aws-cli" --bin-dir "$HOME/.local/bin"
```

Chỉ chạy trong thư mục tạm chứa bộ cài. Trước đó, bảo đảm `command -v aws` không tìm thấy công cụ và cả `~/.local/aws-cli`, `~/.local/bin/aws` đều chưa tồn tại (kể cả liên kết). Nếu có, dừng để kiểm tra bản cũ; không dùng `sudo` hay tùy chọn ghi đè/cập nhật.

### Terraform 1.13.5

1. Mở [trang phát hành 1.13.5 của HashiCorp](https://releases.hashicorp.com/terraform/1.13.5/), tải `terraform_1.13.5_linux_amd64.zip` và `terraform_1.13.5_SHA256SUMS` vào thư mục tạm mới.
2. Trong thư mục đó, kiểm tra checksum:

   ```bash
   sha256sum --check --ignore-missing terraform_1.13.5_SHA256SUMS
   ```

3. Chỉ tiếp tục nếu đúng file ZIP báo `OK`. Giải nén ZIP, tạo `~/.local/bin` nếu chưa có, rồi đặt file thực thi `terraform` vào đó và cấp quyền chạy. Trước khi chép, bảo đảm `command -v terraform` không tìm thấy công cụ và `~/.local/bin/terraform` chưa tồn tại, kể cả liên kết; không ghi đè.

Chỉ tải từ nguồn chính thức. Checksum phát hiện file hỏng/không khớp, **không chứng minh chữ ký nhà phát hành** khi cùng tải từ một máy chủ. Tài liệu này chưa xác minh PGP cho gói AWS hoặc checksum Terraform; muốn xác thực nguồn phát hành, làm theo [hướng dẫn AWS](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) và [HashiCorp](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) về chữ ký và fingerprint trước khi chạy file tải về.

## 3. Cho terminal tìm thấy công cụ

```bash
export PATH="$HOME/.local/bin:$PATH"
aws --version
terraform version
```

Để giữ PATH cho terminal mới, thêm dòng `export PATH="$HOME/.local/bin:$PATH"` **một lần** vào `~/.bashrc` nếu dùng Bash, hoặc `~/.zshrc` nếu dùng Zsh. Dòng export ở trên có hiệu lực ngay trong terminal hiện tại.

## 4. Nhờ admin chuẩn bị quyền và khóa

Nhờ admin làm theo [hướng dẫn IAM](IAM-Lab.vi.md), gồm bổ sung hai quyền object tagging vào policy. Admin tạo access key cho `nooby_handsome_OperatorUser`; user lab không có quyền IAM để tự cấp khóa.

Không dùng khóa root hoặc admin. Secret chỉ hiện lúc tạo: nhập trực tiếp vào file cục bộ bằng editor, không đưa vào lệnh lưu history, chat, ảnh chụp hay Git. Nếu mất secret, nhờ admin thay khóa; nếu lộ, thu hồi/rotate ngay.

Nếu tổ chức dùng SSO, nhờ admin cấp phiên có quyền tương đương và xem [hướng dẫn IAM Identity Center](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html); không trộn quy trình SSO với khóa môi trường bên dưới.

## 5. Tạo file môi trường riêng

Mở terminal dành riêng cho lab, tại **thư mục gốc dự án**. Mẫu thực tế là [`.env.aws.example`](../.env.aws.example), các ô khóa để trống. Nếu chưa có `.env.aws`, sao chép không ghi đè:

```bash
cp -n .env.aws.example .env.aws
chmod 600 .env.aws
```

Nếu file đã tồn tại, giữ nguyên và kiểm tra bằng editor riêng; không in nội dung ra terminal. Điền hai giá trị khóa operator vào các biến đã có. Credentials tạm thời cần thêm `AWS_SESSION_TOKEN` đúng cùng phiên.

Mẫu đã export cả `AWS_DEFAULT_REGION`, `AWS_REGION`, `TF_VAR_aws_region` và `TF_VAR_availability_zone`. Giữ region `ap-southeast-1`, AZ mặc định `ap-southeast-1a`; region không phải bí mật và không lấy từ khóa. Các giới hạn khác đã khóa trong cấu hình: account `565856126571`, môi trường `dev`, máy `t3.micro` và đúng bucket lab.

## 6. Nạp môi trường và kiểm tra đúng danh tính

Sau khi điền khóa, chạy **trong cùng terminal ở thư mục gốc**:

```bash
unset AWS_PROFILE AWS_DEFAULT_PROFILE AWS_SESSION_TOKEN AWS_SECURITY_TOKEN
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
source ./.env.aws
aws sts get-caller-identity --no-cli-pager
```

Lệnh unset bỏ profile/khóa/token cũ trước khi nạp file. Nếu dùng credentials tạm thời, file phải export lại token mới cùng khóa. `source` thực thi nội dung shell: chỉ nạp file tin cậy; AWS CLI và Terraform không tự đọc file dotenv.

**Dừng nếu kết quả không khớp cả hai:**

- Account: `565856126571`.
- Arn: `arn:aws:iam::565856126571:user/nooby_handsome_OperatorUser`.

STS chỉ kiểm tra danh tính, không tạo hạ tầng. Không dùng `env`, `cat .env.aws` hay `set -x` để kiểm tra khóa. Không chia sẻ tùy tiện đầu ra danh tính; đóng terminal khi xong để bỏ môi trường lab. File bị Git ignore vẫn có thể lộ nếu từng được track hoặc chia sẻ.

## 7. Sẵn sàng thực hành

Đọc [mini project](Terraform.md), rồi làm theo [hướng dẫn chạy và dọn demo](../terraform/README.md) khi chủ động muốn triển khai. Lab chỉ mở HTTP, không SSH; S3 riêng tư và không cấp dữ liệu cho website EC2.

EC2, EBS, IPv4 công khai, S3 và truyền dữ liệu có thể tính phí, không tự động miễn phí. Xem plan và chi phí trước khi apply; budget không phải trần chi tiêu. Sau demo hoặc apply lỗi, kiểm tra tài nguyên còn sót và dọn bằng Terraform. Giữ state an toàn để còn destroy, không xóa state để dọn và không commit khóa/state/plan.
