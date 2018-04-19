#Install AWSPowerShell and .Net Tools
$AwsPowershellUrl = "http://sdk-for-net.amazonwebservices.com/latest/AWSToolsAndSDKForNet.msi"
$AwsPowershellDir = "$($env:TEMP)\AwsPowershell"
$AwsPowershellPath = Join-Path -Path $AwsPowershellDir -ChildPath "AWSToolsAndSDKForNet.msi"
If(Test-Path -Path $AwsPowershellPath -PathType Leaf)
{
    Get-Item -Path $AwsPowershellPath | Remove-Item -Force
}
If(!(Test-Path -Path $AwsPowerShellDir -PathType Container))
{
    MKDIR $AwsPowershellDir
}

$HttpClient = New-Object -TypeName System.Net.WebClient
$HttpClient.DownloadFile($AwsPowershellUrl, $AwsPowershellPath)
Start-Process -FilePath $env:SystemRoot\System32\msiexec.exe -ArgumentList "/i", "$AwsPowershellPath", "/quiet" -Wait  
