# Decisions

## D1: Custom VPC Over Default VPC

**Decision**: Provision a dedicated VPC (10.10.0.0/16) rather than deploying into the AWS default VPC.

**Alternatives**:
- Default VPC (already exists, no Terraform needed)
- VPC with multiple subnets and NAT gateway

**Tradeoffs**:
- Custom VPC: full control over CIDR, clean isolation from other workloads, but more Terraform resources
- Default VPC: simpler but shared with other experiments, no control over CIDR
- Multi-subnet: unnecessary for single-instance personal VPN

**Justification**: Isolation from other AWS workloads. If the VPN instance is compromised, the blast radius is limited to this VPC. Also demonstrates VPC provisioning skills for portfolio purposes. Single subnet is sufficient for a single-instance deployment.

**Source**: `main.tf` (aws_vpc, aws_subnet, aws_internet_gateway)

---

## D2: SSM Session Manager Over SSH-Only Access

**Decision**: Attach IAM role with `AmazonSSMManagedInstanceCore` policy for Systems Manager access, making SSH optional.

**Alternatives**:
- SSH-only access (requires key management, port 22 exposure)
- SSM-only (no SSH at all)
- Both SSM + SSH (current approach)

**Tradeoffs**:
- SSM: no key files to manage, no port 22 needed, audit trail in CloudTrail
- SSH: familiar, works without AWS CLI, but requires key distribution
- Both: flexibility at cost of slightly larger attack surface (port 22 still open)

**Justification**: SSM is the preferred access method (no key exposure, auditable). SSH is kept as fallback with CIDR restriction. The `enable_keypair` variable allows disabling SSH entirely.

**Source**: `main.tf` (aws_iam_role, aws_iam_role_policy_attachment, aws_key_pair with count)

---

## D3: t2.micro Over Larger Instance Types

**Decision**: Use `t2.micro` (1 vCPU, 1GB RAM) for the VPN server.

**Alternatives**:
- `t3.micro` (newer generation, slightly better networking)
- `t3.small` (2GB RAM, better for Pi-hole with large blocklists)
- ARM-based `t4g.micro` (cheaper, but WireGuard kernel module support varies)

**Tradeoffs**:
- `t2.micro`: free tier eligible for 12 months, sufficient for single-user VPN
- `t3.micro`: $0.0104/hr vs $0.0116/hr (t2), burstable with baseline
- `t3.small`: overkill for personal use, doubles cost
- `t4g.micro`: cheapest long-term but ARM compatibility concerns

**Justification**: Free tier eligibility for the first year. After free tier, cost is ~$8.47/month — acceptable for a personal VPN. Single-user WireGuard + DNS filtering doesn't need more than 1GB RAM.

**Source**: `variables.tf` (instance_type default = "t2.micro")

---

## D4: WireGuard Over OpenVPN

**Decision**: Use WireGuard as the VPN protocol instead of OpenVPN or IPSec.

**Alternatives**:
- OpenVPN (mature, widely supported, more complex)
- IPSec/IKEv2 (enterprise standard, complex configuration)
- Tailscale/Nebula (mesh VPN, managed service)

**Tradeoffs**:
- WireGuard: ~4000 lines of code (auditable), kernel-level performance, modern cryptography, simple config
- OpenVPN: more features (TCP fallback, obfuscation) but slower, larger attack surface
- IPSec: enterprise-grade but complex to configure correctly
- Tailscale: easiest but adds third-party dependency

**Justification**: WireGuard provides the best performance-to-complexity ratio for a personal VPN. Single UDP port, minimal configuration, and kernel-level encryption. The protocol is formally verified and included in the Linux kernel since 5.6.

**Source**: `main.tf` (SG rule: port 51820/UDP), `README.md` (WireGuard validation section)

---

## D5: Single AZ Over Multi-AZ

**Decision**: Deploy in a single availability zone with no redundancy.

**Alternatives**:
- Multi-AZ with auto-scaling group (automatic failover)
- Multi-region (geo-redundancy)
- Elastic IP for stable addressing

**Tradeoffs**:
- Single AZ: lowest cost, simplest, but no automatic recovery from AZ failure
- Multi-AZ: ~2x cost, adds complexity (ASG, health checks, EIP)
- Elastic IP: $3.60/month when instance is stopped (cost when not in use)

**Justification**: This is a personal VPN, not a business-critical service. AZ failures are rare and brief. Manual recovery (terraform apply) is acceptable. No Elastic IP because the instance runs 24/7 — IP changes only on stop/start which is infrequent.

**Source**: `main.tf` (single aws_subnet, single aws_instance), `README.md` ("Not enterprise-grade HA")

---

## D6: Dynamic Public IP Over Elastic IP

**Decision**: Use auto-assigned public IP rather than an Elastic IP.

**Alternatives**:
- Elastic IP (static, persists across stop/start)
- Dynamic DNS service (Route53 or third-party)

**Tradeoffs**:
- Dynamic IP: free while running, but changes on stop/start (requires client config update)
- Elastic IP: free while attached to running instance, $3.60/month if instance stopped
- Dynamic DNS: adds complexity but solves the IP change problem

**Justification**: The instance runs 24/7 for VPN availability. IP only changes if the instance is stopped and restarted, which is rare. Updating the WireGuard client config with a new IP is a minor inconvenience vs. paying for an EIP during any downtime.

**Source**: `main.tf` (associate_public_ip_address = true, no aws_eip resource)
