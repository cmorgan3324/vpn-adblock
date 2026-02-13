# Personal VPN + Ad-Blocking Infrastructure

> **Terraform-managed AWS infrastructure providing secure remote access via WireGuard VPN with DNS-level ad-blocking. Cost-optimized for personal use at ~$9-12/month.**

[![Terraform](https://img.shields.io/badge/IaC-Terraform-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/Cloud-AWS-FF9900?logo=amazon-aws)](https://aws.amazon.com/)
[![WireGuard](https://img.shields.io/badge/VPN-WireGuard-88171A?logo=wireguard)](https://www.wireguard.com/)

## Overview

This project demonstrates infrastructure-as-code best practices for deploying a production-ready VPN solution on AWS. Built to showcase cloud architecture skills for Solutions Architect roles, it emphasizes security, cost optimization, and operational simplicity.

**Key Highlights:**
- 🏗️ **Infrastructure as Code**: 10 Terraform-managed resources with modular, reusable configuration
- 🔒 **Security-First Design**: SSM Session Manager, IAM least privilege, VPC isolation
- 💰 **Cost-Optimized**: Free-tier eligible t2.micro, single-AZ deployment (~$9-12/month)
- ⚡ **Modern Stack**: WireGuard protocol, Amazon Linux 2023, automated provisioning

## Architecture

```
┌─────────────────────────────────────────┐
│           AWS us-east-1                 │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │ VPC (10.10.0.0/16)                │ │
│  │                                   │ │
│  │  ┌─────────────────────────────┐ │ │
│  │  │ Public Subnet (us-east-1a)  │ │ │
│  │  │                             │ │ │
│  │  │  ┌───────────────────────┐  │ │ │
│  │  │  │ EC2 (t2.micro)        │  │ │ │
│  │  │  │ - WireGuard VPN       │  │ │ │
│  │  │  │ - SSM Agent           │  │ │ │
│  │  │  │ - Security Group      │  │ │ │
│  │  │  └───────────────────────┘  │ │ │
│  │  └─────────────────────────────┘ │ │
│  │                                   │ │
│  │  Internet Gateway                 │ │
│  └───────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

**Components:**
- **VPC**: Isolated network (10.10.0.0/16)
- **EC2**: t2.micro instance running Amazon Linux 2023
- **Security Group**: Restricted ingress (SSH 22/tcp, WireGuard 51820/udp)
- **IAM Role**: SSM-only permissions (no S3, database, or service access)
- **SSM**: Secure shell access without SSH keys or bastion hosts

## Technical Skills Demonstrated

**For Solutions Architect Roles:**
- Infrastructure as Code (Terraform)
- AWS networking (VPC, subnets, route tables, internet gateways)
- Security architecture (IAM, security groups, least privilege)
- Cost optimization strategies (free-tier usage, single-AZ deployment)
- Systems management (SSM Session Manager)

**Architecture Decisions:**
- **Single-AZ**: Cost optimization over high availability (acceptable for personal use)
- **t2.micro**: Free-tier eligible, sufficient for VPN traffic
- **SSM over SSH**: Eliminates key management, reduces attack surface
- **No Elastic IP**: Dynamic IP acceptable for personal use, saves $3.60/month

## Quick Start

```bash
# Clone repository
git clone https://github.com/cmorgan3324/vpn-adblock.git
cd vpn-adblock

# Configure variables (optional)
cat > terraform.tfvars << EOF
aws_region           = "us-east-1"
aws_profile          = "personal"
allowed_ssh_cidr     = "YOUR_IP/32"  # Lock down SSH
EOF

# Deploy infrastructure
terraform init
terraform plan
terraform apply

# Get instance details
terraform output instance_public_ip
terraform output instance_id
```

## Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region | `us-east-1` |
| `instance_type` | EC2 instance type | `t2.micro` |
| `vpc_cidr` | VPC CIDR block | `10.10.0.0/16` |
| `allowed_ssh_cidr` | SSH access restriction | `0.0.0.0/0` ⚠️ |

**Security Recommendation**: Set `allowed_ssh_cidr` to your public IP `/32`

## Operations

**Connect via SSM (recommended):**
```bash
INSTANCE_ID=$(terraform output -raw instance_id)
aws ssm start-session --target $INSTANCE_ID
```

**Connect via SSH (fallback):**
```bash
PUBLIC_IP=$(terraform output -raw instance_public_ip)
ssh -i ~/.ssh/personal_vpn ec2-user@$PUBLIC_IP
```

## Cost Analysis

| Resource | Monthly Cost |
|----------|--------------|
| EC2 t2.micro (730 hrs) | ~$8.47 |
| EBS gp3 8GB | ~$0.80 |
| Data transfer (first 100GB) | Free |
| **Total** | **~$9-12/month** |

**Cost Drivers:**
- Instance runtime (24/7 operation)
- Data transfer for VPN traffic
- EBS storage (minimal)

## Security

**Implemented:**
- ✅ VPC isolation
- ✅ Security group ingress controls
- ✅ IAM least privilege (SSM-only)
- ✅ SSM Session Manager (no SSH keys required)
- ✅ Configurable SSH CIDR restrictions

**Recommended Hardening:**
- Enable VPC Flow Logs
- Add CloudWatch alarms for unusual activity
- Rotate WireGuard keys periodically
- Set up AWS Budget alerts


## Technologies

**Cloud & IaC:**
- AWS (EC2, VPC, IAM, Systems Manager)
- Terraform
- Amazon Linux 2023

**Networking & Security:**
- WireGuard VPN
- VPC networking
- Security groups
- IAM roles

## License

MIT License - see [LICENSE](LICENSE) for details.

---

**Portfolio**: [vibebycory.dev](https://vibebycory.dev) | **LinkedIn**: [cory-c-morgan](https://linkedin.com/in/cory-c-morgan) | **GitHub**: [@cmorgan3324](https://github.com/cmorgan3324)
