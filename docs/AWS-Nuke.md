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

3. Rename the extracted executable file to:

<b>Windows: <i>aws-nuke.exe</i></b>

<b>Linux/Mac: <i>aws-nuke</i></b>

4. Unblock or set the correct permissions on the file:

Windows: 
In PowerShell in terminal navigate to the directory where you extracted aws-nuke and execute the following command.

<b>Windows</b>
```PowerShell
Unblock-File aws-nuke.exe
```

<b>Linux/Mac</b>
In terminal navigate to the directory where you extracted aws-nuke and execute the following command.

```sh
chmod +x aws-nuke 
```

5. Create the AWS-Nuke Configuration File with using the following content as a guide under the file name aws-nuke.yaml

```yaml
regions:
- eu-west-1
- global

account-blocklist:
- "999999999999" # production
- "999999999998" # SSO login

accounts:
- "000000000000": {} # AWS Account number to be nuked
```


6.	Execute AWS-Nuke in as a Dry-Run

```cmd
aws-nuke.exe -c nuke-config.yml --profile <ACCOUNT PROFILE>
```

Linux/Mac
```sh
./aws-nuke -c nuke-config.yml --profile <ACCOUNT PROFILE>
```

7. Using the output of the dry run, amend the AWS-Nuke configuration file to include your username, user access key and user policy attachment.

```yaml
regions:
- eu-west-1
- global


account-blocklist:
- "999999999999" # production
- "999999999998" # SSO login

accounts:
- "000000000000": {}# aws-nuke-example

filters:
  IAMUser:
  - "my-user"
  IAMUserPolicyAttachment:
  - "my-user -> AdministratorAccess"
  IAMUserAccessKey:
  - "my-user -> ABCDEFGHIJKLMNOPQRST"
```

8. Execute AWS-Nuke 

<b>Windows</b>
```cmd
aws-nuke.exe -c nuke-config.yml --profile <ACCOUNT PROFILE> --no-dry-run
```

<b>Linux/Mac</b>
```sh
aws-nuke -c nuke-config.yml --profile <ACCOUNT PROFILE> --no-dry-run
```
