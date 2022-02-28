# AWS-Nuke

AWS-Nuke is an opensource utility for clearing AWS Accounts. It is reasonably well featured and will remove most AWS resources types from an account. 

The utility can be downloaded from https://github.com/rebuy-de/aws-nuke/releases

Before using the utility configure either your. aws/credential file, or your .aws/config file so that you are able to use AWS Cli to access the account you wish to clear.  As there are many possible configurations of your AWS credentials file will not be covered in this document. 

<b>It is recommended to the use the root account on the AWS Account you want to Nuke</b>


1. Download AWS-Nuke from the following location.

<b>Windows</b>
https://github.com/rebuy-de/aws-nuke/releases/download/v2.17.0/aws-nuke-v2.17.0-windows-amd64.zip

<b>Mac Intel</b>
https://github.com/rebuy-de/aws-nuke/releases/download/v2.17.0/aws-nuke-v2.17.0-darwin-amd64.tar.gz 

<b>Mac M1</b>
https://github.com/rebuy-de/aws-nuke/releases/download/v2.17.0/aws-nuke-v2.17.0-darwin-arm64.tar.gz

<b>Linux</b>
https://github.com/rebuy-de/aws-nuke/releases/download/v2.17.0/aws-nuke-v2.17.0-linux-amd64.tar.gz


2. Unzip AWS-Nuke to a directory of your choice.

<b>Windows</b>
```PowerShell
Expand-Archive -Path aws-nuke-v2.17.0-windows-amd64.zip -DestinationPath .
```

<b>MacOS Intel</b>
```sh
tar -xvf aws-nuke-v2.17.0-darwin-arm64.tar.gz
```
<b>MacOS M1</b>
```sh
tar -xvf aws-nuke-v2.17.0-darwin-arm64.tar.gz
```

<b>Linux</b>
```sh
tar -xvf aws-nuke-v2.17.0-linux-amd64.tar.gz
