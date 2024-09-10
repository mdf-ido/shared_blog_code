# Create AMI and Trigger Terraform

This GitHub Action workflow creates an AMI using Packer and triggers a Terraform workflow using the created AMI ID as a payload.

## Workflow Triggers

This workflow is triggered by the `workflow_dispatch` event, which allows manual triggering of the workflow.

## Jobs

### packer

This job runs on a self-hosted Linux runner and performs the following steps:

1. Checkout Repository: This step checks out the repository using the `actions/checkout` action.

2. Setup `packer`: This step sets up Packer using the `hashicorp/setup-packer` action.

3. Initialize Packer Template: This step initializes the Packer template using the `packer init` command.

4. Validate Packer Template: This step validates the Packer template using the `packer validate` command.

5. Build AMI: This step builds the AMI using the `packer build` command and sets the `GHTOKEN` variable as a secret.

6. Set AMI ID as output: This step extracts the AMI ID from the Packer manifest file and sets it as an output variable.

7. Get AMI: This step retrieves the AMI ID from the output variable and prints it.

### trigger_another_repo

This job runs on an Ubuntu runner and triggers another workflow in a different repository using the AMI ID obtained from the `packer` job.

1. Trigger second workflow: This step sends a POST request to the GitHub API to trigger the specified workflow in the `repo_name` repository. It includes the AMI ID as a payload in the `client_payload` field.

Note: Replace `repo_name` and `workflow_name` with the actual repository and workflow names.

## terraform
# Terraform after Packer

This GitHub Action workflow is triggered by the `trigger_prod_tf_build` event and is designed to be used with Terraform and Packer. It performs various Terraform operations on machine infrastructure based on the AMI obtained from the payload.

## Workflow Details

- Workflow Name: Terraform after Packer
- Trigger: `repository_dispatch` event with type `trigger_prod_tf_build`
- Manual Trigger: Enabled (`workflow_dispatch`)

## Job Details

- Job Name: tfbuild
- Runner Type: self-hosted, linux
- Working Directory: `./machine/tf`

## Steps

1. Checkout Repository: Checks out the repository under `$GITHUB_WORKSPACE` so that the job can access it.
2. Print Event Payload: Prints the value of the `variable_name` property from the `client_payload` of the GitHub event.
3. Check TF Version: Prints the version of Terraform installed.
4. Terraform init: Initializes Terraform with the specified backend configuration.
5. Terraform validation: Validates the Terraform configuration.
6. Terraform plan: Generates a Terraform plan based on the specified variables and saves it to `tf.plan`.
7. Terraform apply: Applies the Terraform plan and builds the infrastructure if the value of `TF` is set to `'build'`.
8. Terraform Plan Destroy: Generates a Terraform plan for destroying the infrastructure if the value of `TF` is set to `'destroy'`.
9. Terraform Destroy: Applies the Terraform plan for destroying the infrastructure if the value of `TF` is set to `'destroy'`.

Note: The environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are used for authentication with AWS.