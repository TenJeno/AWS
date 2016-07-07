Nuget TerraForm
===============

This Terraform creates a Nuget Server using the Nuget.Server nuget package found at GitHub.Com/BrokenFlame/NugetServer/releases.

_If you are new to TerraForm please read the following:_
1. Download and install Terraform for your platform from Terraform.io
2. Download this folder to your local drive.
3. Make sure you have an AWS Credential file in your user profile. AWS has provided instructions on how to do this. http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-config-file
4. Open the file named environment and change the variables as required. Noting the VPC ID, and Subnet ID you would like to deploy the Nuget Server into, as well as the KeyPair name to use.
5. From commandline navigate to this folder containing the terraform.  
6. At the command prompt type the Terraform command __"terraform get"__ to configure the Terrafrorm module.
7. At the command prompt type the Terraform command __"terraform apply"__ to build the NugetServer in AWS.
