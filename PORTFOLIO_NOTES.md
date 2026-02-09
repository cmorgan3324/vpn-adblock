# VPN + Ad-Blocking Infrastructure - Portfolio Notes

## Project Facts (Code-Derived)

### Infrastructure Components
- **IaC Tool**: Terraform
- **Cloud Provider**: AWS
- **Region**: us-east-1 (from tfstate)
- **Instance Type**: t2.micro (free tier eligible)
- **VPN Protocol**: WireGuard (port 51820/UDP)
- **Deployed**: Yes (active instance at 54.89.90.65)

### Architecture
- **Network**: Custom VPC (10.10.0.0/16)
  - 1 public subnet (10.10.10.0/24) in us-east-1a
  - Internet Gateway for public access
  - Route table with internet route
- **Compute**: 1 EC2 instance (Amazon Linux 2023)
- **Security**: 
  - Security group with SSH (22/tcp) and WireGuard (51820/udp)
  - IAM role with SSM access (AmazonSSMManagedInstanceCore)
  - Optional SSH key pair for fallback access
- **Management**: AWS Systems Manager (SSM) for secure shell access

### Resource Count
- 1 VPC
- 1 Internet Gateway
- 1 Public Subnet
- 1 Route Table + 1 Route
- 1 Security Group
- 1 EC2 Instance (t2.micro)
- 1 IAM Role + 1 Policy Attachment + 1 Instance Profile
- 1 EC2 Key Pair (optional)

**Total Managed Resources**: ~10 resources

### Cost Analysis
**Monthly estimate (us-east-1, 730 hours/month)**:
- EC2 t2.micro: $0.0116/hour × 730 = ~$8.47/month
- EBS gp3 8GB (default AL2023): ~$0.80/month
- Data transfer OUT (first 100GB free, then $0.09/GB)
- **Estimated total**: ~$9-12/month (excluding data transfer)

**Cost drivers**:
- Instance runtime (24/7 operation)
- Data transfer for VPN traffic
- EBS storage

### Security Features
- SSM-based access (no exposed SSH required)
- Configurable SSH CIDR restriction
- VPC isolation
- Security group ingress controls
- IAM least-privilege role

### TBDs (Verification Commands)

**Ad-blocking software status**:
```bash
aws ssm start-session --target i-03ef2897490b69cbb \
  --document-name AWS-StartInteractiveCommand \
  --parameters command="systemctl status pihole-FTL || systemctl status unbound || echo 'Not installed'"
```

**DNS configuration**:
```bash
aws ssm start-session --target i-03ef2897490b69cbb \
  --document-name AWS-StartInteractiveCommand \
  --parameters command="cat /etc/resolv.conf && netstat -tulpn | grep :53"
```

**WireGuard configuration status**:
```bash
aws ssm start-session --target i-03ef2897490b69cbb \
  --document-name AWS-StartInteractiveCommand \
  --parameters command="wg show || echo 'WireGuard not configured'"
```

**Actual monthly cost (requires AWS credentials)**:
```bash
aws ce get-cost-and-usage \
  --time-period Start=2025-01-01,End=2025-02-01 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --filter file://<(echo '{"Tags":{"Key":"Project","Values":["personal-vpn"]}}')
```

## Project Description (ATS/Interview-Ready)

**Title**: Personal VPN + Ad-Blocking Infrastructure

**Summary**: Terraform-managed AWS infrastructure providing secure VPN access with DNS-level ad-blocking. Provisions isolated VPC networking, WireGuard VPN server, and systems management capabilities on cost-optimized compute.

**Key Points**:
- Infrastructure-as-code using Terraform (10 managed resources)
- Custom VPC with public subnet and internet gateway
- WireGuard VPN protocol (modern, performant alternative to OpenVPN)
- AWS Systems Manager integration for secure instance management
- Security group controls limiting attack surface
- Free tier eligible (t2.micro instance)
- Estimated $9-12/month operational cost

**Technical Highlights**:
- Single-AZ deployment (cost optimization over high availability)
- IAM role with SSM policy for passwordless shell access
- Configurable SSH CIDR restrictions
- Amazon Linux 2023 base image
- User data bootstrap for system updates

**Tradeoffs**:
- Single AZ = no automatic failover (acceptable for personal use)
- Public IP (not Elastic IP) = IP changes on stop/start
- No CloudWatch detailed monitoring (cost optimization)
- Manual VPN client configuration required

**Use Case**: Personal privacy tool for secure browsing on untrusted networks, DNS-level ad blocking, and geo-restriction bypass.
