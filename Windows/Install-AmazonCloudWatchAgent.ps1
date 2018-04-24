 #Install AmazonCloudWatchAgent
$AmazonCloudWatchAgentUrl = "https://s3.amazonaws.com/amazoncloudwatch-agent/windows/amd64/latest/AmazonCloudWatchAgent.zip"
$AmazonCloudWatchAgentDir = "$($env:TEMP)\AmazonCloudWatchAgent"
$AmazonCloudWatchAgentPath = Join-Path -Path $AmazonCloudWatchAgentDir -ChildPath "AmazonCloudWatchAgent.zip"
$AmazonCloudWatchAgentExPath = 

If(Test-Path -Path $AmazonCloudWatchAgentDir -PathType Container)
{
    Get-Item -Path $AmazonCloudWatchAgentDir | Remove-Item -Force -Recurse
}
If(!(Test-Path -Path $AmazonCloudWatchAgentDir -PathType Container))
{
    MKDIR $AmazonCloudWatchAgentDir
}

$HttpClient = New-Object -TypeName System.Net.WebClient
$HttpClient.DownloadFile($AmazonCloudWatchAgentUrl, $AmazonCloudWatchAgentPath)
Unblock-File -Path $AmazonCloudWatchAgentPath

#[System.Reflection.Assembly]::LoadWithPartialName("System.Io.Compression.Filesystem")
Add-Type -assembly "System.Io.Compression.Filesystem"
[Io.Compression.ZipFile]::ExtractToDirectory($AmazonCloudWatchAgentPath, $AmazonCloudWatchAgentDir)

Push-Location $AmazonCloudWatchAgentDir
.\install.ps1
Pop-Location

　
Push-Location $env:ProgramFiles\Amazon\AmazonCloudWatchAgent
.\amazon-cloudwatch-agent-ctl.ps1 -a fetch-config -m ec2 -c file:$env:ProgramFiles\Amazon\AmazonCloudWatchAgent\config.json -s
Pop-Location 
