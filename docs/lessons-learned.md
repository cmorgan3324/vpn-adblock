# Lessons Learned

## L1: Terraform Provisions Infrastructure, Not Software

**What happened**: The Terraform code provisions the VPC, EC2 instance, security groups, and IAM roles — but does not install WireGuard or DNS ad-blocking software. The user_data script only runs `dnf -y update`.

**Root cause**: Deliberate separation of concerns. Infrastructure provisioning (Terraform) is kept separate from configuration management (manual or Ansible). This avoids coupling software versions to infrastructure lifecycle.

**Resolution**: Documented that WireGuard and DNS software installation is a manual post-deploy step. The README includes validation commands but not installation steps.

**Takeaway**: For portfolio projects, clearly document what is automated vs. manual. Recruiters reading the README should understand the boundary between IaC and configuration management. Consider adding an Ansible playbook or user_data script for full automation in a future iteration.

**Source**: `main.tf` (user_data = `dnf -y update` only), `README.md` (WireGuard Validation section)

---

## L2: Default SSH CIDR of 0.0.0.0/0 is a Security Risk

**What happened**: The `allowed_ssh_cidr` variable defaults to `0.0.0.0/0` in `variables.tf`, which opens SSH to the entire internet if no tfvars override is provided.

**Root cause**: Terraform requires a default value for variables to allow `terraform plan` without a tfvars file. Using `0.0.0.0/0` as default makes the code "work" out of the box but is insecure.

**Resolution**: README explicitly warns "Do not leave SSH open to 0.0.0.0/0" and shows how to set the variable. The SECURITY.md document reinforces this.

**Takeaway**: For security-sensitive defaults, consider using `null` with a validation block that forces the user to provide a value, or use a `precondition` that fails if the CIDR is too broad. Example:
```hcl
variable "allowed_ssh_cidr" {
  validation {
    condition     = can(cidrhost(var.allowed_ssh_cidr, 0)) && !contains(["0.0.0.0/0"], var.allowed_ssh_cidr)
    error_message = "SSH CIDR must not be 0.0.0.0/0"
  }
}
```

**Source**: `variables.tf` (allowed_ssh_cidr default), `README.md` (warning)

---

## L3: No Remote State Backend Limits Collaboration

**What happened**: Terraform state is stored locally (`terraform.tfstate`). The `.gitignore` correctly excludes it from version control, but there's no remote backend for state sharing or locking.

**Root cause**: Single-developer personal project — remote state adds complexity (S3 bucket + DynamoDB table) without immediate benefit.

**Resolution**: Accepted as appropriate for a personal project. State file is gitignored. If the project were to be shared or CI/CD added, an S3 backend would be required.

**Takeaway**: For portfolio projects, document why you chose local state (cost, simplicity) and note that production deployments would use remote state with locking. This shows awareness of the tradeoff without over-engineering.

**Source**: `providers.tf` (no backend block), `.gitignore` (*.tfstate)

---

## L4: WireGuard Port Open to 0.0.0.0/0 is Intentional

**What happened**: The security group allows UDP 51820 from `0.0.0.0/0` (any source), which might appear overly permissive.

**Root cause**: WireGuard clients connect from varying IP addresses (mobile networks, coffee shops, etc.). Restricting the source CIDR would break VPN access from new locations.

**Resolution**: This is by design. WireGuard's cryptographic handshake (Curve25519 key exchange) means that only clients with the correct private key can establish a tunnel. The open port is not a vulnerability — unauthenticated packets are silently dropped.

**Takeaway**: Document intentional security decisions that might look like oversights. Explain why the WireGuard port is open (cryptographic authentication at the protocol level) vs. why SSH is restricted (password/key-based authentication is weaker).

**Source**: `main.tf` (SG ingress rule for 51820/UDP with 0.0.0.0/0)

---

## L5: Secrets Management for VPN Credentials

**What happened**: VPN passwords and WireGuard keys need to be stored somewhere for operational use, but must never be committed to the repository.

**Root cause**: WireGuard private keys and Pi-hole admin passwords are generated during manual setup and need to be accessible for client configuration and admin access.

**Resolution**: Created a `secrets/` directory (gitignored) for local credential storage. The `.gitignore` covers `secrets/`, `*.pem`, `*.key`, and `*.conf` patterns. Verified that `git ls-files secrets/` returns empty (not tracked).

**Takeaway**: Always verify gitignore effectiveness with `git ls-files` or `git status`. A gitignore entry only prevents future tracking — if a file was committed before the gitignore rule was added, it remains tracked. Use `git rm --cached` to untrack previously committed secrets.

**Source**: `.gitignore` (secrets/ pattern), `secrets/vpn-passwords.env` (exists locally, not tracked)
