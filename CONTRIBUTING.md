# Contributing to VPN + Ad-Blocking Infrastructure

Thank you for considering contributing to this project! This is a personal infrastructure project, but improvements and suggestions are welcome.

## How to Contribute

### Reporting Issues

If you find a bug or have a suggestion:

1. Check existing issues to avoid duplicates
2. Open a new issue with:
   - Clear description of the problem/suggestion
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - Terraform version and AWS region
   - Relevant log output (redact sensitive info)

### Submitting Changes

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow existing code style
   - Update documentation as needed
   - Test changes in your own AWS account
   - Ensure `terraform fmt` and `terraform validate` pass

4. **Commit with clear messages**
   ```bash
   git commit -m "Add: Brief description of change"
   ```

5. **Push and create a pull request**
   ```bash
   git push origin feature/your-feature-name
   ```

## Development Guidelines

### Terraform Standards

- Use consistent naming conventions (see existing resources)
- Add comments for complex logic
- Use variables for configurable values
- Tag all resources with `Project` tag
- Run `terraform fmt` before committing
- Run `terraform validate` to check syntax

### Security

- Never commit secrets, keys, or credentials
- Use `.gitignore` for sensitive files
- Prefer IAM roles over access keys
- Document security implications of changes
- Follow principle of least privilege

### Documentation

- Update README.md for user-facing changes
- Add inline comments for complex Terraform logic
- Update variable descriptions
- Document new outputs
- Include examples for new features

### Testing

Before submitting:

1. **Validate syntax**
   ```bash
   terraform fmt -check
   terraform validate
   ```

2. **Test in isolated environment**
   ```bash
   terraform plan
   terraform apply
   # Test functionality
   terraform destroy
   ```

3. **Check for secrets**
   ```bash
   git diff | grep -i "secret\|password\|key"
   ```

## Code of Conduct

- Be respectful and constructive
- Focus on the technical merits
- Help others learn
- Keep discussions on-topic

## Questions?

Open an issue for questions or clarifications. I'll respond as time permits.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
