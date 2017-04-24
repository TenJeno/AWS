 #C:\ProgramData\PuppetLabs\facter\fact.d\AWSFacts.ps1
$instanceTags = New-Object -TypeName System.Management.Automation.PSObject
try 
{
    $instanceRegionResponse = (Invoke-RestMethod -Method Get -Uri "http://169.254.169.254/latest/dynamic/instance-identity/document").region
    $instanceRegion = $instanceRegionResponse
    Write-Output "ec2_placement_region=$instanceRegion"

    $instanceIdResponse = Invoke-RestMethod -Method Get -Uri "http://169.254.169.254/latest/meta-data/instance-id"
    $instanceId=$instanceIdResponse
    Import-Module AWSPowerShell
    $filteredTags = Get-EC2Tag | Where {$_.ResourceId -eq $instanceId}
    foreach($tag in $filteredTags)
    {
        $instanceTags | Add-Member -MemberType NoteProperty -Name $tag.Key -Value $tag.Value
        Write-Output "$($tag.Key)=$($tag.Value)"
    }
}
catch
{
    Write-Debug "Could not get AWS Region."
} 
