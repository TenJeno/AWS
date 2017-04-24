 #Download the redistributables in paralel to save time.
[string]$redistDir = "c:\redist"
If(!(Test-Path -Path $redistDir))
{
    MKDIR $redistDir
}
$puppetAgentInstaller = [System.Tuple]::Create("Puppet-Agent", "$redistDir\puppet-x64-latest.msi", "https://downloads.puppetlabs.com/windows/puppet-x64-latest.msi")

$downloads = New-Object System.Collections.ArrayList
$downloads.Add($puppetAgentInstaller) | Out-Null

foreach ($download in $downloads)
{
    Write-Verbose "Downloading $($download.Item1) from $($download.Item3) to $($download.Item2)"
    Start-Job { Invoke-WebRequest $using:download.Item3 -Method Get -OutFile $using:download.Item2 } 
}
Get-Job | Wait-Job
$downloads.Clear()
Get-Job | Remove-Job

$puppetAgentIsInstalled = Get-WmiObject -Class Win32_Product | where {$_.IdentifyingNumber -eq "{C132DF61-207E-4C59-90B8-1DA9E2E1A754}"}
if($puppetAgentIsInstalled -eq $null)
{
    Start-Process -FilePath msiexec -ArgumentList "/I", "$($puppetAgentInstaller.Item2)","/qn", "/norestart" -wait
}
 
