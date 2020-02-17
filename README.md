# CloudFormation Deploy Github Action

A simple github action to deploy a CloudFormation file.

* Deploy existing or new stacks
* Read outputs back into future steps

## Example

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Load AWS Credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      - name: Deploy App Stack
        id: deploy
        uses: alexjurkiewicz/cfn-deploy@v2.0.1
        with:
          stackName: myapp
          templateFile: myapp.cfn.yml
          parameters: MinInstances=2 MaxInstances=8 VpcId=${{ secrets.vpc_id }}
      - name: Print App Hostname
        run: echo ${{ steps.deploy.outputs.cf_output_AppHostname }}
```

## Inputs

* `stackName` **REQUIRED** CloudFormation stack name.
* `templateFile` **REQUIRED** Path to your CloudFormation template file.
* `parameters` Stack parameters. Format is `key1=val1 key2=val2`. If your parameter values have whitespace, use `parameterFile`.
* `parameterFile` File with stack parameters. Format is one `key=val` per line.
* `capabilities` Required CloudFormation capabilities, eg `CAPABILITY_IAM` or `CAPABILITY_NAMED_IAM`.
* `noExecuteChangeset` If defined, create a CloudFormation change set but do not execute it.

## Accessing stack outputs

CloudFormation stack outputs are exported as Github Action step outputs.

Access using `${{ steps.<id>.outputs.cf_output_<outputname> }}`.

Example:

```yaml
      - uses: alexjurkiewicz/cfn-deploy@v2.0.0
        id: cfn-deploy
        with:
          stackName: myapp
          templateFile: myapp.cfn.yml
      - run: echo The hostname is ${{ steps.cfn-deploy.outputs.cf_output_Hostname }}
```

Note: you MUST give the source step an `id` property for outputs to be accessible.

## Examples

### Add Parameters

You can add parameters in two ways: directly and via a file.

```yaml
      - uses: alexjurkiewicz/cfn-deploy@v2.0.0
        id: cfn-deploy
        with:
          stackName: myapp
          templateFile: myapp.cfn.yml
          parameters: DbUser=myapp DbPass=${{secrets.DbPass}}
          parameterFile: params.txt
```

Parameter file format:

```ini
DbHostname=db.myapp.com
DbDescription=Spaces (and other special characters!) are allowed in the parameter file
```

### Capabilities & No Execute Changeset

```yaml
      - uses: alexjurkiewicz/cfn-deploy@v2.0.0
        id: cfn-deploy
        with:
          stackName: myapp
          templateFile: myapp.cfn.yml
          capabilities: CAPABILITY_IAM # or CAPABILITY_NAMED_IAM
          noExecuteChangeset: true
```

If `noExecuteChangeset` is `true`, you can still read stack outputs, but they will be the current outputs (eg before the change set is executed).

## Development

Contributions welcome.

A simple test harness is in `test/`. To use, provide it with real AWS credentials. It will create a stack called "test":

```sh
AWS_DEFAULT_REGION=x AWS_ACCESS_KEY_ID=x AWS_SECRET_ACCESS_KEY=x test/test.sh
```

## Credits

This module was forked from [intuit/cfn-deploy](https://github.com/intuit/cfn-deploy) (at
ca43cf6).
