# CLAUDE.md

## Writing Style
- Dense, technical, no fluff
- Bullet points + code blocks over prose
- Assume technical reader

## Documentation
- **Format**: `.org` files only (not Markdown)
- **Literate programming**: Use Org Babel with `:results output :eval no-export` for executable code blocks
- **Naming**: `README.org` (not `README.md`)

## Repository
- **Stack**: AWS CDK + TypeScript + ES modules (`tsx` for execution, no build)
- **Environment**: Nix flakes (Node.js 24, AWS CLI v2) + direnv
- **Public repo**: Never commit secrets (AWS account IDs, credentials, IPs)

## Structure
```
aws/
├── backup/          # Backup infrastructure
├── core/            # Shared foundation (VPC, IAM roles)
├── lib/             # Shared utilities, constructs
│   └── config.ts    # resourceName(), standardTags(), regions
└── deploy.ts        # CDK app entry
```

## Naming
- Resources: `<app>-<env>-<purpose>` (e.g., `truenas-prod-backup`)
- Use `lib/config.ts` utilities for consistency

## IAM Organization
- **core/**: Shared roles/policies referenced by multiple stacks
- **application folders**: Purpose-specific IAM users (TrueNAS, etc.)

## Commands
- `npm run synth` - Preview CloudFormation
- `npm run deploy` - Deploy
- `npm run diff` - Compare with deployed

## Key Files
- `aws/README.org`: Deployment docs
- `cdk.json`: CDK config
- `flake.nix`: Nix environment
