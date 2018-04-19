#Install AWS CodeDeploy
$Region = (Invoke-RestMethod -Uri http://169.254.169.254/latest/dynamic/instance-identity/document).region
$CodeDeployDir = "$($env:TEMP)\CodeDeploy"
If(!(Test-Path -Path $CodeDeployDir -PathType Container))
{
    MKDIR $CodeDeployDir
}
$CodeDeployPath = Join-Path -Path $CodeDeployDir -ChildPath "codedeploy-agent.msi"
$CodeDeployUrl = @{ "us-east-2" = "https://aws-codedeploy-us-east-2.s3.amazonaws.com/latest/codedeploy-agent.msi"; `
    "us-east-1" = "https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/codedeploy-agent.msi"; `
    "us-west-1" = "https://aws-codedeploy-us-west-1.s3.amazonaws.com/latest/codedeploy-agent.msi"; `
    "us-west-2" = "https://aws-codedeploy-us-west-2.s3.amazonaws.com/latest/codedeploy-agent.msi"; `
    "ca-central-1" = "https://aws-codedeploy-ca-central-1.s3.amazonaws.com/latest/codedeploy-agent.msi"; `
    "eu-west-1" = "https://aws-codedeploy-eu-west-1.s3.amazonaws.com/latest/codedeploy-agent.msi"; `
    "eu-west-2" = "https://aws-codedeploy-eu-west-2.s3.amazonaws.com/latest/codedeploy-agent.msi"; `
    "eu-west-3" = "https://aws-codedeploy-eu-west-3.s3.amazonaws.com/latest/codedeploy-agent.msi"; `
    "eu-central-1" = "https://aws-codedeploy-eu-central-1.s3.amazonaws.com/latest/codedeploy-agent.msi"; `
    "ap-northeast-1" = "https://aws-codedeploy-ap-northeast-1.s3.amazonaws.com/latest/codedeploy-agent.msi"; `
    "ap-northeast-2" = "https://aws-codedeploy-ap-northeast-2.s3.amazonaws.com/latest/codedeploy-agent.msi"; `
    "ap-southeast-1" = "https://aws-codedeploy-ap-southeast-1.s3.amazonaws.com/latest/codedeploy-agent.msi"; `
    "ap-southeast-2" = "https://aws-codedeploy-ap-southeast-2.s3.amazonaws.com/latest/codedeploy-agent.msi"; `
    "ap-south-1" = "https://aws-codedeploy-ap-south-1.s3.amazonaws.com/latest/codedeploy-agent.msi"; `
    "sa-east-1" = "https://aws-codedeploy-sa-east-1.s3.amazonaws.com/latest/codedeploy-agent.msi"}
$HttpClient = New-Object -TypeName System.Net.WebClient
$HttpClient.DownloadFile($CodeDeployUrl["$Region"], $CodeDeployPath)
Start-Process -FilePath $env:SystemRoot\System32\msiexec.exe -ArgumentList "/i", "$CodeDeployPath", "/quiet" -Wait  
