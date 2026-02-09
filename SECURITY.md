# Security Policy

## Supported Versions

This is a personal infrastructure project. Security updates will be applied to the latest version only.

| Version | Supported          |
| ------- | ------------------ |
| Latest  | :white_check_mark: |
| Older   | :x:                |

## Security Considerations

### Infrastructure Security

This project provisions cloud infrastructure with the following security characteristics:

**Strengths:**
- VPC isolation from other AWS resources
- Security group ingress controls (SSH, WireGuard only)
- IAM role with minimal permissions (SSM only)
- Systems Manager for secure shell access (no SSH key required)
- Configurable SSH CIDR restrictions

**Limitations:**
- Single AZ deployment (no automatic failover)
- Public IP address (not behind load balancer)
- Default SSH CIDR is `0.0.0.0/0` (must be locked down)
- No WAF or DDoS protection
- No VPC Flow Logs enabled by default
- No CloudWatch alarms configured

### Recommended Security Hardening

1. **Lock down SSH access**
   ```hcl
   allowed_ssh_cidr = "YOUR_PUBLIC_IP/32"
   ```

2. **Use SSM instead of SSH**
   ```bash
   aws ssm start-session --target INSTANCE_ID
   ```

3. **Enable VPC Flow Logs** (add to Terraform)
   ```hcl
   resource "aws_flow_log" "vpc" {
     vpc_id          = aws_vpc.this.id
     traffic_type    = "ALL"
     iam_role_arn    = aws_iam_role.flow_logs.arn
     log_destination = aws_cloudwatch_log_group.flow_logs.arn
   }
   ```

4. **Add CloudWatch alarms** for unusual activity

5. **Rotate WireGuard keys** periodically

6. **Enable AWS GuardDuty** in your account

7. **Set up AWS Budget alerts** to detect unexpected usage

### Secrets Management

**Never commit:**
- AWS credentials
- SSH private keys
- WireGuard private keys
- Terraform state files (may contain sensitive data)
- `terraform.tfvars` (may contain IPs or paths)

**Use `.gitignore`** to prevent accidental commits:
```
*.tfstate
*.tfstate.*
*.tfvars
*.pem
*.key
secrets/
```

### VPN Security

**WireGuard best practices:**
- Use strong pre-shared keys
- Rotate keys periodically
- Limit peer connections
- Monitor connection logs
- Use kill switch on clients

**DNS security:**
- Configure DNSSEC validation (Unbound)
- Use DNS-over-HTTPS (DoH) if needed
- Monitor DNS query logs for anomalies

## Reporting a Vulnerability

If you discover a security vulnerability:

1. **Do NOT open a public issue**
2. **Email**: cmorgan3324@gmail.com
3. **Include**:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### Response Timeline

- **Initial response**: Within 48 hours
- **Status update**: Within 7 days
- **Fix timeline**: Depends on severity
  - Critical: Within 7 days
  - High: Within 14 days
  - Medium: Within 30 days
  - Low: Best effort

### Disclosure Policy

- Security issues will be fixed before public disclosure
- Credit will be given to reporters (unless anonymity requested)
- CVE will be requested for critical vulnerabilities
- Public disclosure after fix is deployed and users notified

## Security Checklist

Before deploying to production:

- [ ] Set `allowed_ssh_cidr` to your IP `/32`
- [ ] Review security group rules
- [ ] Enable VPC Flow Logs
- [ ] Set up CloudWatch alarms
- [ ] Configure AWS Budget alerts
- [ ] Enable GuardDuty
- [ ] Review IAM permissions
- [ ] Rotate all keys and credentials
- [ ] Test SSM access
- [ ] Document incident response plan
- [ ] Set up automated backups
- [ ] Review Terraform state security

## Known Limitations

1. **No encryption at rest** for EBS volumes (can be enabled)
2. **No multi-factor authentication** for VPN (WireGuard limitation)
3. **No rate limiting** on VPN connections
4. **No DDoS protection** beyond AWS Shield Standard
5. **No automated security patching** (manual updates required)

## Compliance

This infrastructure is designed for personal use and has not been audited for compliance with:
- HIPAA
- PCI DSS
- SOC 2
- ISO 27001
- GDPR (data residency considerations needed)

If you need compliance, additional controls are required.

## References

- [AWS Security Best Practices](https://aws.amazon.com/security/best-practices/)
- [WireGuard Security](https://www.wireguard.com/formal-verification/)
- [Terraform Security](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [OWASP Cloud Security](https://owasp.org/www-project-cloud-security/)

## Contact

For security concerns: cmorgan3324@gmail.com

For general questions: Open an issue on GitHub
