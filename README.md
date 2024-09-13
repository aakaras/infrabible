# Terraform Azure OpenAI Deployment

This Terraform project automates the deployment of Azure OpenAI instances and multiple models available in Azure. It simplifies the process of setting up and managing Azure Cognitive Services, ensuring that your AI models are deployed efficiently and reliably.

## Features

- **Automated Deployment**: Deploy Azure OpenAI instances and models with minimal manual intervention.
- **Scalability**: Easily scale your AI models based on your requirements.
- **Lifecycle Management**: Manage the lifecycle of your deployments, ensuring that resources are created and destroyed in the correct order.
- **Retry Mechanism**: Handle deployment conflicts with a retry mechanism to ensure successful deployments.

## Resources

### 1. Cognitive Deployment

The `azurerm_cognitive_deployment` resource is used to deploy AI models. It includes the following attributes:
- **name**: The name of the deployment.
- **cognitive_account_id**: The ID of the Azure Cognitive Account.
- **rai_policy_name**: The Responsible AI policy name associated with the deployment.
- **model**: The model details including format, name, and version.
- **scale**: The scaling configuration including type and capacity.
- **lifecycle**: Lifecycle management to ensure resources are created and destroyed in the correct order.
- **depends_on**: Ensures that deployments are deleted before content filters to avoid dependency issues.

### 2. Null Resource for Retry Mechanism

A `null_resource` is used to implement a retry mechanism for handling deployment conflicts:
- **provisioner "local-exec"**: Executes a shell script to retry the deployment in case of conflicts.
- **triggers**: Ensures the retry mechanism runs every time.

## Variables

- **var.models**: A map of models to be deployed, including their format, name, version, scale type, and scale capacity.

## Usage

1. **Define Variables**: Ensure you have the necessary variables defined in your `terraform.tfvars` file or through other means.
2. **Initialize Terraform**: Run the following command to initialize Terraform:
    ```sh
    terraform init
    ```
3. **Apply Configuration**: Apply the Terraform configuration to deploy the resources:
    ```sh
    terraform apply -auto-approve
    ```

## Benefits

- **Efficiency**: Automates the deployment process, saving time and reducing the risk of manual errors.
- **Scalability**: Easily scale your AI models to meet your application's demands.
- **Reliability**: Ensures that resources are managed correctly with lifecycle management and retry mechanisms.
- **Flexibility**: Supports multiple AI models, allowing you to deploy a variety of models based on your needs.

## Example

Here is an example of how to define the models in your `terraform.tfvars` file:

```hcl
models = {
  "gpt-4o-mini-deployment" = {
    model_format    = "OpenAI"
    model_name      = "gpt-4"
    model_version   = "4.0"
    scale_type      = "Standard"
    scale_capacity  = 1
    rai_policy_name = "default"
  },
  "Dall-e-3" = {
    model_format    = "OpenAI"
    model_name      = "dall-e"
    model_version   = "3.0"
    scale_type      = "Standard"
    scale_capacity  = 1
    rai_policy_name = "default"
  }
}

## Conclusion

This Terraform project provides a robust and efficient way to deploy Azure OpenAI instances and multiple models. By automating the deployment process, it ensures that your AI models are deployed quickly and reliably, allowing you to focus on building and improving your applications.
```

This documentation provides an overview of the Terraform project, its features, usage instructions, and benefits. It also includes an example configuration to help users get started.