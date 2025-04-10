# Terraform React

## Action Usage

```
jobs:
  deploy-react:
    uses: woragis/terraform-react/.github/actions/deploy@main
    with:
      project-name: my-project
      terraform-dir: ./infra/react
      aws-region: us-east-1

  setup-route53:
    needs: deploy-react
    uses: woragis/terraform-route53/.github/actions/setup@main
    with:
      s3-bucket-name: ${{ needs.deploy-react.outputs.s3-bucket-name }}
```
