# Terraform Infrastructure Setup

This repository contains Infrastructure as Code (IaC) using [Terraform](https://www.terraform.io/) to provision cloud resources.

## Prerequisites

Before you begin, ensure you have met the following requirements:

- Terraform installed (version 1.5.0 or higher)
- An AWS account (or any other cloud provider you're using)
- Properly configured AWS credentials (if you're using AWS)

## Getting Started

Follow these steps to use the Terraform configuration in this repository:

### 1. Clone the Repository

```
git clone https://github.com/your-repo/terraform-iac.git
cd terraform-iac
```

### 2. Initialize Terraform

Run the following command to initialize the working directory. This will download any necessary provider plugins:

```
terraform init
```

### 3. Format Terraform Code

Ensure your Terraform code is properly formatted:

```
terraform fmt -recursive
```

### 4. Validate the Configuration

To verify that your Terraform configuration is syntactically correct, run:

```
terraform validate
```

### 5. Apply the Configuration

To create or modify the infrastructure as described in your configuration, run the following command:

```
terraform apply
```

Terraform will display a plan and ask for confirmation before applying changes.

### 6. Destroy the Infrastructure

If you need to clean up and destroy all the resources created by Terraform, you can run:

```
terraform destroy
```

## Notes

- Make sure your cloud provider credentials are properly configured before running Terraform commands. For AWS, you can configure credentials using the `aws configure` command or by setting environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`).
- Before making changes, always run `terraform plan` to see what Terraform will do without applying any changes.