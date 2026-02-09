# Quick Push Instructions

## 1. Create GitHub Repository

Go to: https://github.com/new

- **Name**: `vpn-adblock`
- **Description**: Terraform-managed AWS infrastructure for WireGuard VPN with DNS-level ad-blocking
- **Visibility**: Public
- **Do NOT** initialize with README, .gitignore, or license (we have them)

Click "Create repository"

## 2. Push Code

```bash
cd /Users/corymorgan/Documents/aws-projects/vpn-adblock

# Add remote
git remote add origin https://github.com/cmorgan3324/vpn-adblock.git

# Push
git push -u origin main

# Optional: Tag release
git tag -a v0.1.0 -m "Initial public release"
git push origin v0.1.0
```

## 3. Verify

```bash
# Check remote
git remote -v

# View on GitHub
open https://github.com/cmorgan3324/vpn-adblock
```

## 4. Update Resume PDF (Optional)

```bash
cd /Users/corymorgan/Documents/aws-projects/portfolio-site

# Start server
python3 -m http.server 8000

# Open: http://localhost:8000/resume/index.html
# Print to PDF (Cmd+P → Save as PDF)
# Save as: Cory_Morgan_SA_Resume.pdf
# Replace existing PDF in portfolio-site root
```

---

**That's it!** See `INTEGRATION_REPORT.md` for full details.
