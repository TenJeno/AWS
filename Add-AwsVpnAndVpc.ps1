.EXAMPLE
   Add-AwsVpnAndVpc -VpcCiderBlock 10.0.0.0/16 -TagPrefix MyTag -CustomerIP 31.200.0.1 -OfficeCidrBlock 192.168.16.0/24
#>
function Add-AwsVpnAndVpc
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        [string]$VpcCiderBlock,
        [string]$TagPrefix,
        [string]$CustomerIP,
        [string]$OfficeCidrBlock
    )

    Begin
    {
    }
    Process
    {
        $Vpc = New-EC2Vpc -CidrBlock $VpcCiderBlock
        New-EC2Tag -Resources $Vpc.VpcId -Tags @{ Key = "Name"; Value = "$TagPrefix-eu-vpc" }

        $DefaultSecurityGroup = Get-EC2SecurityGroup -Filter @{ Name = "vpc-id"; Values = $Vpc.VpcId }
        Revoke-EC2SecurityGroupIngress -GroupId $DefaultSecurityGroup.GroupId -IpPermissions $DefaultSecurityGroup.IpPermissions
        Revoke-EC2SecurityGroupEgress -GroupId $DefaultSecurityGroup.GroupId -IpPermissions $DefaultSecurityGroup.IpPermissionsEgress

        $DefaultNetworkAcl = Get-EC2NetworkAcl  -Filter @{ Name = "vpc-id"; Values = $Vpc.VpcId }
        Remove-EC2NetworkAclEntry -NetworkAclId $DefaultNetworkAcl.NetworkAclId -RuleNumber 100 -Egress:$False -Force
        Remove-EC2NetworkAclEntry -NetworkAclId $DefaultNetworkAcl.NetworkAclId -RuleNumber 100 -Egress:$True -Force

        $InternetGateway = New-EC2InternetGateway
        New-EC2Tag -Resources $InternetGateway.InternetGatewayId -Tags @{ Key = "Name"; Value = "$TagPrefix-eu-vpc-igw" }
        Add-EC2InternetGateway -VpcId $Vpc.VpcId -InternetGatewayId $InternetGateway.InternetGatewayId

        $VPNGateway = New-EC2VpnGateway -Type ipsec.1
        New-EC2Tag -Resources $VPNGateway.VpnGatewayId -Tags @{ Key = "Name"; Value = "$TagPrefix-eu-vpc-vgw" }
        Add-EC2VpnGateway -VpcId $Vpc.VpcId -VpnGatewayId $VPNGateway.VpnGatewayId

        $CustomerGateway = New-EC2CustomerGateway -Type ipsec.1 -PublicIp $CustomerIP
        New-EC2Tag -Resources $CustomerGateway.CustomerGatewayId -Tags @{ Key = "Name"; Value = "$TagPrefix-eu-vpc-cgw-office" }

        $VpnConnection = New-EC2VpnConnection -Type ipsec.1 -customerGatewayId $CustomerGateway.CustomerGatewayId -VpnGatewayId $VPNGateway.VpnGatewayId -Options_StaticRoutesOnly:$True
        New-EC2Tag -Resources $VpnConnection.VpnConnectionId -Tags @{ Key = "Name"; Value = "$TagPrefix-eu-vpc-vpn-office" }

        $state = "completed"
        Write-Host "Creating. Please wait..."
        do
        {
            $state = Get-EC2VpnConnection -VpnConnectionIds $VpnConnection.VpnConnectionId | % State
        }
        while ($state -contains "pending")

        New-EC2VpnConnectionRoute -VpnConnectionId $VpnConnection.VpnConnectionId -DestinationCidrBlock $OfficeCidrBlock
        Get-EC2VpnConnection -VpnConnectionId $VpnConnection.VpnConnectionId | % CustomerGatewayConfiguration
    }
    End
    {
    }
}