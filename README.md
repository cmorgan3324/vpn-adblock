# Personal Cloud VPN + Ad-Blocking Infrastructure

Terraform-managed AWS infrastructure providing secure VPN access with DNS-level ad-blocking capabilities. Built for personal privacy, secure browsing on untrusted networks, and cost-optimized cloud deployment.

## Overview

This project provisions a complete VPN infrastructure on AWS using modern tooling:
- **WireGuard VPN** for fast, secure tunneling
- **DNS-level ad-blocking** (Pi-hole/Unbound - TBD verification)
- **AWS Systems Manager** for secure instance management
- **Infrastructure as Code** with Terraform
- **Cost-optimized** for personal use (~$9-12/month)

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    AWS us-east-1                        │
│                                                         │
│  ┌───────────────────────────────────────────────────┐ │
│  │ VPC (10.10.0.0/16)                                │ │
│  │                                                   │ │
│  │  ┌─────────────────────────────────────────────┐ │ │
│  │  │ Public Subnet (10.10.10.0/24) - us-east-1a │ │ │
│  │  │                                             │ │ │
│  │  │  ┌──────────────────────────────────────┐  │ │ │
│  │  │  │ EC2 Instance (t2.micro)              │  │ │ │
│  │  │  │ - Amazon Linux 2023                  │  │ │ │
│  │  │  │ - WireGuard VPN (51820/udp)          │  │ │ │
│  │  │  │ - DNS Ad-blocking (TBD)              │  │ │ │
│  │  │  │ - SSM Agent                          │  │ │ │
│  │  │  └──────────────────────────────────────┘  │ │ │
│  │  │                                             │ │ │
│  │  └─────────────────────────────────────────────┘ │ │
│  │                                                   │ │
│  │  Internet Gateway ──────────────────────────────┐│ │
│  └──────────────────────────────────────────────────┘│ │
│                                                        │
└────────────────────────────────────────────────────────┘
         │                                    ▲
         │ VPN Clients                        │
         └────────────────────────────────────┘
```

### Components

| Component | Purpose | Details |
|-----------|---------|---------|
| **VPC** | Network isolation | 10.10.0.0/16 CIDR |
| **Public Subnet** | Internet-facing resources | 10.10.10.0/24 in us-east-1a |
| **Internet Gateway** | Public internet access | Attached to VPC |
| **Security Group** | Firewall rules | SSH (22/tcp), WireGuard (51820/udp) |
| **EC2 Instance** | VPN server | t2.micro, Amazon Linux 2023 |
| **IAM Role** | Instance permissions | SSM access for management |
| **SSM** | Secure shell access | No SSH key required |

**Total Managed Resources**: 10

## Deployment

### Prerequisites

- AWS CLI configured with credentials
- Terraform >= 1.0
- SSH key pair (optional, for fallback access)

### Quick Start

```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/vpn-adblock.git
cd vpn-adblock

# Initialize Terraform
terraform init

# Review planned changes
terraform plan

# Deploy infrastructure
terraform apply

# Get instance public IP
terraform output instance_public_ip
```

### Configuration

Create `terraform.tfvars` to customize deployment:

```hcl
aws_region           = "us-east-1"
aws_profile          = "personal"
instance_type        = "t2.micro"
project_name         = "personal-vpn"
allowed_ssh_cidr     = "YOUR_IP/32"  # Lock down SSH access
ssh_public_key_path  = "~/.ssh/id_rsa.pub"
enable_keypair       = true
```

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region for deployment | `us-east-1` |
| `aws_profile` | AWS CLI profile | `personal` |
| `instance_type` | EC2 instance type | `t2.micro` |
| `vpc_cidr` | VPC CIDR block | `10.10.0.0/16` |
| `public_subnet_cidr` | Public subnet CIDR | `10.10.10.0/24` |
| `allowed_ssh_cidr` | SSH access restriction | `0.0.0.0/0` (⚠️ lock down!) |
| `enable_keypair` | Create EC2 key pair | `true` |

## Security

### Access Control
- **Primary**: AWS Systems Manager (SSM) for secure shell access
- **Fallback**: SSH with key-based authentication (optional)
- **Recommendation**: Set `allowed_ssh_cidr` to your public IP `/32`

### Network Security
- Security group restricts ingress to SSH and WireGuard ports only
- VPC isolation from other AWS resources
- Public subnet for internet-facing VPN endpoint

### IAM Permissions
Instance role has minimal permissions:
- `AmazonSSMManagedInstanceCore` - SSM access only
- No S3, database, or other service access

### Best Practices
1. **Lock down SSH**: Set `allowed_ssh_cidr` to your IP
2. **Use SSM**: Prefer SSM over SSH for management
3. **Rotate keys**: Regenerate WireGuard keys periodically
4. **Monitor costs**: Set up AWS Budget alerts
5. **Review logs**: Check VPN connection logs regularly

## Cost

### Monthly Estimate (us-east-1)

| Resource | Cost |
|----------|------|
| EC2 t2.micro (730 hrs) | ~$8.47 |
| EBS gp3 8GB | ~$0.80 |
| Data transfer (first 100GB) | Free |
| Data transfer (>100GB) | $0.09/GB |
| **Total** | **~$9-12/month** |

### Cost Optimization
- Free tier eligible (t2.micro)
- Single AZ deployment (no multi-AZ costs)
- No Elastic IP (uses dynamic public IP)
- No CloudWatch detailed monitoring
- No NAT Gateway (public subnet only)

### Cost Drivers
- **Instance runtime**: 24/7 operation
- **Data transfer**: VPN traffic egress charges
- **Storage**: EBS volume (minimal)

**TBD**: Verify actual monthly cost with AWS Cost Explorer:
```bash
aws ce get-cost-and-usage \
  --time-period Start=2025-01-01,End=2025-02-01 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --filter '{"Tags":{"Key":"Project","Values":["personal-vpn"]}}'
```

## Operations

### Connect to Instance

**Via SSM (recommended)**:
```bash
# Get instance ID
INSTANCE_ID=$(terraform output -raw instance_id)

# Start session
aws ssm start-session --target $INSTANCE_ID
```

**Via SSH (fallback)**:
```bash
# Get public IP
PUBLIC_IP=$(terraform output -raw instance_public_ip)

# Connect
ssh -i ~/.ssh/personal_vpn ec2-user@$PUBLIC_IP
```

### Configure WireGuard

**TBD**: Verify WireGuard installation and configuration:
```bash
aws ssm start-session --target $INSTANCE_ID \
  --document-name AWS-StartInteractiveCommand \
  --parameters command="wg show"
```

### Configure Ad-Blocking

**TBD**: Verify Pi-hole/Unbound installation:
```bash
aws ssm start-session --target $INSTANCE_ID \
  --document-name AWS-StartInteractiveCommand \
  --parameters command="systemctl status pihole-FTL || systemctl status unbound"
```

## Architecture Decisions

### Why WireGuard?
- Modern, audited cryptography
- Faster than OpenVPN (kernel-level implementation)
- Simpler configuration
- Lower overhead

### Why Single AZ?
- Cost optimization for personal use
- Acceptable downtime risk
- Easy to redeploy if needed
- No cross-AZ data transfer costs

### Why t2.micro?
- Free tier eligible
- Sufficient for personal VPN traffic
- Low cost (~$8.47/month)
- Easy to upgrade if needed

### Why No Elastic IP?
- Cost savings ($3.60/month)
- Dynamic IP acceptable for personal use
- Can be added later if needed


## License

MIT License - see [LICENSE](LICENSE) for details.

## Acknowledgments

- [WireGuard](https://www.wireguard.com/) - Fast, modern VPN protocol
- [Pi-hole](https://pi-hole.net/) - Network-wide ad blocking
- [Unbound](https://nlnetlabs.nl/projects/unbound/) - Validating DNS resolver
- [Terraform](https://www.terraform.io/) - Infrastructure as Code
