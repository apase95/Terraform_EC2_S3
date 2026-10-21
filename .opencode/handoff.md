# Task: AWS/Terraform workstation onboarding

- Project: /home/hodangthaiduy/Workspace/Projects/DemoTerraform; not a Git repository, revision unavailable.
- OpenArms selection: no skill package loaded; task lock is this AWS/Terraform onboarding request. No skill filesystem access.
- Provider/model: openai/gpt-6.1-sol. Scout: explore, ses_ea019cd96ffeouUnvrXeGskBtn. Implementer: general, ses_ea018c743ffer2ygO1fhOWldCc (fresh task).
- Completion: tools installed user-locally; controller independently verified AWS CLI 2.38.4, Terraform 1.13.5, Bash syntax and local environment file mode 600. No AWS authentication/deployment attempted. Terraform is pinned, not latest.
- Progress: scout read docs/Terraform.md. Controller confirmed Linux x86_64, aws and terraform absent from PATH. Only docs currently visible; no AGENTS found by scout.

## Scope
User (Vietnamese) asks read docs/Terraform.md especially section 5, help download/install AWS CLI v2 and Terraform CLI, explain where AWS access/secret/default region originate, create separate environment file. Implement safe Vietnamese guide docs/AWS-Installation.vi.md, .env.aws.example and local .env.aws (blank credentials only), .gitignore, and optional installer script for Linux x86_64 user-local installs without sudo. No credentials solicited or invented; no AWS deployments or paid resources. Do not modify whole tutorial or implement mini project.

Prefer actual user-local install if shell tools available; otherwise create robust installer script controller can execute. Use official AWS CLI v2 download and official Terraform releases with pinned stable version >=1.5 and SHA256 verification (explain checksum vs signature trust). Avoid overwriting existing tools. User-local ~/.local/bin with PATH guidance, no sudo. Scope writes outside project only tool install paths if running installer. Network failures must be reported honestly.

Env file: explicit exports AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY blank, region ap-southeast-1; AWS_REGION and TF_VAR_aws_region synchronized; TF_VAR_availability_zone likewise since tutorial hardcodes default AZ. Optional session token commented and warn stale tokens/profiles. Explain source file (not auto dotenv) and chmod 600. Ignore local env/state/plans/.terraform but preserve lockfile. Link guide near section 5.

Guide: IAM user Security credentials > Access keys > Create access key (CLI), secret only visible at creation, never root credentials, least privilege not AdminAccess, recommend SSO/temporary creds and MFA, region is chosen not secret (Singapore ap-southeast-1). SSO setup alternative avoid env credential precedence. Never print secrets, source only trusted shell file. Verification aws --version, terraform version, aws sts get-caller-identity only after user fills keys. Warn SSH 0.0.0.0/0 vs diagram and paid EC2/public IPv4/storage, destroy after lab. Terraform source is embedded markdown not actual .tf files.

## Mandatory checks
No existing test/build framework found. Run shell syntax checks for scripts/env, verify no real secrets, inspect changes, versions if installed. No terraform apply/plan/init against AWS or credential retrieval. No commits. Do not spawn tasks or read skills. Return files changed, test results, installation status and blockers.
