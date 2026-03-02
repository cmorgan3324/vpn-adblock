# Personal VPN + Ad-Blocking on AWS (WireGuard + Terraform)

A Terraform-managed AWS setup that gives you: - A personal WireGuard VPN
endpoint - DNS-level ad-blocking (so ads get rejected at the door, not
after they move in) - A cost-conscious footprint (\~\$9-$12/mo after Free tier limits)

If you can follow steps and tolerate mild troubleshooting, you're good.

------------------------------------------------------------------------

## What you're building

-   AWS VPC (10.10.0.0/16)
-   Public subnet in a single AZ
-   EC2 t2.micro running Amazon Linux 2023
-   WireGuard on UDP 51820
-   SSM Session Manager for admin access
-   Security Group with restricted ingress
-   Terraform-managed infrastructure

### Why this design exists

This is a personal VPN. You are optimizing for: - Low cost - Low
operational overhead - Clean infrastructure-as-code

Not enterprise-grade HA.

------------------------------------------------------------------------

## Before you start

You need:

1.  AWS account
2.  Terraform installed
3.  AWS CLI installed and configured
4.  IAM permissions for VPC, EC2, IAM, and SSM
5.  Your public IP for ingress restriction

Optional but recommended: - AWS Budget alerts - Basic comfort with Linux
CLI

------------------------------------------------------------------------

## Quick Start (Terraform)

### 1) Clone the repository

``` bash
git clone https://github.com/cmorgan3324/vpn-adblock.git
cd vpn-adblock
```

### 2) Configure variables

Create terraform.tfvars:

``` hcl
aws_region       = "us-east-1"
aws_profile      = "personal"
allowed_ssh_cidr = "YOUR_PUBLIC_IP/32"
```

Do not leave SSH open to 0.0.0.0/0.

### 3) Deploy

``` bash
terraform init
terraform plan
terraform apply
```

### 4) Retrieve outputs

``` bash
terraform output instance_id
terraform output instance_public_ip
```

------------------------------------------------------------------------

## Access the Instance

### Preferred: SSM

``` bash
INSTANCE_ID=$(terraform output -raw instance_id)
aws ssm start-session --target "$INSTANCE_ID"
```

This avoids SSH key exposure.

------------------------------------------------------------------------

## WireGuard Validation

Check service status:

``` bash
sudo systemctl status wg-quick@wg0 --no-pager
sudo wg show
```

If wg0 is not active, the VPN is not functioning.

Ensure: - UDP 51820 allowed in Security Group - Client endpoint matches
server public IP

------------------------------------------------------------------------

## Client Setup

1.  Generate client configuration (.conf file)
2.  Import into WireGuard app (mobile or desktop)
3.  Activate tunnel
4.  Verify IP routing and DNS resolution

------------------------------------------------------------------------

## DNS Ad-Blocking Validation

From client:

``` bash
nslookup doubleclick.net
nslookup googleadservices.com
```

Expected result: blocked / NXDOMAIN / 0.0.0.0 depending on
configuration.

If ads still load, your client is likely not using VPN DNS.

------------------------------------------------------------------------

## Operations

Update system:

``` bash
sudo dnf update -y
sudo reboot
```

Rotate keys periodically. Remove stale peers.

------------------------------------------------------------------------

## Cost Profile

Estimated monthly cost: \~\$9-$12 (after Free tier limits)

Primary cost drivers: - EC2 runtime - EBS storage - Data transfer

------------------------------------------------------------------------

## Security Posture

Implemented: - VPC isolation - Restricted Security Group ingress - IAM
role for SSM - No required public SSH exposure

Recommended Enhancements: - AWS Budget alerts - CloudWatch monitoring -
VPC Flow Logs

------------------------------------------------------------------------

## Troubleshooting

### SSM Issues

-   Check IAM role
-   Confirm amazon-ssm-agent running
-   Verify outbound internet access

### WireGuard No Handshake

-   Confirm UDP 51820 open
-   Validate public IP
-   Verify correct key pairing

### DNS Not Blocking

-   Confirm DNS in client config
-   Verify server DNS service active

------------------------------------------------------------------------

## Tear Down

``` bash
terraform destroy
```

This removes all Terraform-managed infrastructure.

------------------------------------------------------------------------

## License

MIT
