# Terraform Azure Infrastructure Project

This project uses Terraform to provision a basic infrastructure setup in Azure, including a Resource Group, Virtual Network, Subnet, Network Security Group, Public IP, Network Interface, and a Linux Virtual Machine.

## Prerequisites

Before you begin, ensure you have the following installed on your local machine:

- [Terraform](https://www.terraform.io/downloads.html)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- An Azure account with sufficient permissions

## Project Structure

```bash
.
├── main.tf                # Main Terraform configuration file
├── variables.tf           # Defines the input variables for the project
├── terraform.tfvars       # Specifies the actual values for the variables
├── customdata.tpl         # Custom data template for VM provisioning
├── linux-ssh-script.tpl   # SSH script template for Linux hosts
├── windows-ssh-script.tpl # SSH script template for Windows hosts
└── README.md              # Project documentation (this file)
```

## Terraform Configuration Overview

### Providers

The project uses the `azurerm` provider to interact with Azure resources. The required provider is specified with a version constraint to ensure compatibility.

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.0.1"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
}
```

### Resources

The following resources are created:

1. **Resource Group**: A logical container to hold the resources.
2. **Virtual Network**: A virtual network for organizing network resources.
3. **Subnet**: A subnet within the virtual network.
4. **Network Security Group**: Controls inbound and outbound traffic for the subnet.
5. **Public IP Address**: A dynamic public IP address for the virtual machine.
6. **Network Interface**: Connects the VM to the subnet and public IP.
7. **Linux Virtual Machine**: A VM running Ubuntu 22.04 LTS, provisioned with SSH access.

### Outputs

The output of the Terraform script provides the public IP address of the virtual machine:

```hcl
output "public_ip_address" {
  value = "${azurerm_linux_virtual_machine.demo-vm.name}: ${data.azurerm_public_ip.ip-data.ip_address}"
}
```

## Variables

The project uses the following variables, which should be defined in a `terraform.tfvars` file or passed during Terraform commands:

- `azure_subscription_id`: Your Azure subscription ID.
- `rg-location`: The location/region for the resources (e.g., `East US`).
- `env`: The environment tag (e.g., `dev`, `staging`, `prod`).
- `admin-user`: The admin username for the VM.
- `ssh_file`: Path to your SSH key file.
- `host_os`: Your host operating system (either `linux` or `windows`).

Example `terraform.tfvars`:

```hcl
azure_subscription_id = "your-subscription-id"
rg-location = "East US"
env = "dev"
admin-user = "your-username"
ssh_file = "/path/to/your/ssh-key"
host_os = "linux"
```

## Usage

### Initialize the Project

Before you start, initialize the Terraform project by running:

```bash
terraform init
```

### Apply the Configuration

To create the resources defined in the configuration files, run:

```bash
terraform apply
```

Review the plan and type `yes` to proceed.

### Destroy the Resources

To clean up and delete the resources created by Terraform, run:

```bash
terraform destroy
```

## Security Considerations

- **Do not include sensitive information** such as `subscription_id`, `admin_user`, or SSH keys directly in your code. Use variables and environment variables to manage sensitive data.
- Ensure that your SSH keys are kept secure and not shared publicly.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

Feel free to modify and extend this README file based on your specific project requirements.