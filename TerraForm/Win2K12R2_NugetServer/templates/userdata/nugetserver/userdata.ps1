<powershell>
#Download NuGet Server
[string]$packageFolder = "$($env:SystemDrive)\packages"
if(!(Test-Path -Path $packageFolder))
{
    MKDIR "$packageFolder"
}
[string]$strDownloadDest = "$packageFolder\Nuget.Server.Octopacked.2.11.2.nupkg"
[string]$strDownloadAddress = "https://github.com/BrokenFlame/NugetServer/releases/download/v2.11.2/Nuget.Server.Octopacked.2.11.2.nupkg"
(New-Object -TypeName System.Net.WebClient).DownloadFile("$strDownloadAddress", "$strDownloadDest")

#Install IIS and .net components
Add-WindowsFeature -Name Web-Server,Web-Asp-Net45,Web-IP-Security, Web-Http-Redirect, Web-Mgmt-Console, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-WebSockets, Web-IP-Security
#Remove Default-WebSite
$defaultWebsite = Get-Website | Where {$_.Name -eq "Default Web Site"}
if($defaultWebsite -ne $null)
{
    Remove-Website -Name $defaultWebsite.name 
}

#Unzip NuGet Server
[string]$NugetServerDir = "$($env:systemdrive)\inetpub\nugetserver"
if(!(Test-Path -Path $packageFolder))
{
    MKDIR "$NugetServerDir"
}

[string]$NugetWebConfigFile = "$NugetServerDir\Web.config"
Add-Type -AssemblyName "System.IO.Compression.FileSystem"
[System.IO.Compression.ZipFile]::ExtractToDirectory($strDownloadDest, $NugetServerDir )

#Set web.config
If(Test-Path -Path $NugetWebConfigFile)
{
    [xml]$webConfig = [xml](Get-Content $NugetWebConfigFile)
    $root = $xml.get_DocumentElement()
    $webConfig.SelectSingleNode('//appSettings/add[@key="apiKey"]/@value').'#text' = "${apiKey}"
    $webConfig.SelectSingleNode('//appSettings/add[@key="packagesPath"]/@value').'#text' = "${packagesPath}"
    $webConfig.Save($NugetWebConfigFile)

    #Configure IIS Website
    $nugetWebsite =  Get-Website | Where {$_.Name -eq "Nuget.Server"}
    if($nugetWebsite -eq $null)
    {
        New-Website -Name "Nuget.Server" -Port 80 -PhysicalPath "$($env:SystemDrive)\inetpub\nugetserver"
    }

    $NugetHttpRule = Get-NetFirewallRule | Where {$_.Name -eq "Nuget"}
    If($NugetHttpRule -eq $null)
    {
        New-NetFirewallRule -Name Nuget -DisplayName "NugetServer (HTTP)" -Description "Allow Access to NugetServer" -Protocol TCP -LocalPort 80 -Enabled True -Profile Any -Action Allow 
    }

    $NugetSSLRule = Get-NetFirewallRule | Where {$_.Name -eq "NugetSSL"}
    If($NugetHttpRule -eq $null)
    {
        New-NetFirewallRule -Name NugetSSL -DisplayName "NugetServer (HTTPS)" -Description "Allow Access to NugetServer" -Protocol TCP -LocalPort 443 -Enabled True -Profile Any -Action Allow 
    }

}

#Rename the computer to match the AWS Instance ID
$instanceid = (New-Object System.Net.WebClient).DownloadString("http://169.254.169.254/latest/meta-data/instance-id")
[string]$computerName = $($Env:COMPUTERNAME)
if($computerName -ne $instanceid)
{
    Rename-Computer -NewName $instanceid -Force -Restart
}

</powershell>