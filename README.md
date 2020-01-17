# CloudFormation Deploy Github Action

A simple github action to deploy a CloudFormation file.

* Deploy existing or new stacks
* Read outputs back into future steps

## Contents

* [Usage](#usage)
* [Accessing stack outputs](#accessing-stack-outputs)
* [Development](#development)
* Credits

## Usage

Read [actions.yml](actions.yml) for a full parameter listing.

Supply AWS credentials with the [aws-actions/configure-aws-credentials](https://github.com/aws-actions/configure-aws-credentials) action.

Example usage:

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-west-2
      - uses: alexjurkiewicz/cfn-deploy@v2.0.0
        with:
          stackName: myapp
          templateFile: myapp.cfn.yml
          parameters: "DbUser=myapp DbPass=${{secrets.DbPass}}"
```

## Accessing stack outputs

CloudFormation stack outputs are made available as Github Action step outputs.

Access using `${{ steps.<id>.outputs.cf_output_<outputname> }}`.

Example:

```yaml
      - uses: alexjurkiewicz/cfn-deploy@v2.0.0
        id: cfn-deploy
        with:
          stackName: myapp
          templateFile: myapp.cfn.yml
          parameters: "DbUser=myapp DbPass=${{secrets.DbPass}}"
      - run: echo 'The hostname is ${{ steps.cfn-deploy.outputs.cf_output_Hostname }}'

```

Note: you MUST give the step an `id` property for outputs to be accessible.

## Development

Contributions welcome.

A simple test harness is in `test/`. To use, provide it with real AWS credentials. It will create a stack called "test":

```sh
AWS_DEFAULT_REGION=x AWS_ACCESS_KEY_ID=x AWS_SECRET_ACCESS_KEY=x test/test.sh
```

## Credits

This module was originally forked from [intuit/cfn-deploy](https://github.com/intuit/cfn-deploy) (at
ca43cf6).
