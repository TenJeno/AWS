$RdsCertificateUrl = @{"root" = "https://s3.amazonaws.com/rds-downloads/rds-ca-2015-root.pem";
                        "ap-south-1" = "https://s3.amazonaws.com/rds-downloads/rds-ca-2015-ap-south-1.pem";
                        "ap-northeast-1" = "https://s3.amazonaws.com/rds-downloads/rds-ca-2015-ap-northeast-1.pem";
                        "ap-northeast-2" = "https://s3.amazonaws.com/rds-downloads/rds-ca-2015-ap-northeast-2.pem";
                        "ap-northeast-3" = "https://s3.amazonaws.com/rds-downloads/rds-ca-2015-ap-northeast-3.pem";
                        "ap-southeast-1" = "https://s3.amazonaws.com/rds-downloads/rds-ca-2015-ap-southeast-1.pem";
                        "ap-southeast-2" = "https://s3.amazonaws.com/rds-downloads/rds-ca-2015-ap-southeast-2.pem";
                        "ca-central-1" = "https://s3.amazonaws.com/rds-downloads/rds-ca-2015-ca-central-1.pem";
                        "cn-north-1" = "https://s3.amazonaws.com/rds-downloads/rds-cn-north-1-ca-certificate.pem";
                        "cn-northwest-1" = "https://s3.amazonaws.com/rds-downloads/rds-ca-cn-northwest-1.pem";
                        "eu-central-1" = "https://s3.amazonaws.com/rds-downloads/rds-ca-2015-eu-central-1.pem";
                        "eu-west-1" = "https://s3.amazonaws.com/rds-downloads/rds-ca-2015-eu-west-1.pem";
                        "eu-west-2" = "https://s3.amazonaws.com/rds-downloads/rds-ca-2015-eu-west-2.pem";
                        "eu-west-3" = "https://s3.amazonaws.com/rds-downloads/rds-ca-2015-eu-west-3.pem";
                        "sa-east-1" = "https://s3.amazonaws.com/rds-downloads/rds-ca-2015-sa-east-1.pem";
                        "us-east-1" = "https://s3.amazonaws.com/rds-downloads/rds-ca-2015-us-east-1.pem";
                        "us-east-2" = "https://s3.amazonaws.com/rds-downloads/rds-ca-2015-us-east-2.pem";
                        "us-west-1.pem" = "https://s3.amazonaws.com/rds-downloads/rds-ca-2015-us-west-1.pem";
                        "rds-ca-2015-us-west-2.pem" = "https://s3.amazonaws.com/rds-downloads/rds-ca-2015-us-west-2.pem";
                        "us-gov-west-1" = "https://s3-us-gov-west-1.amazonaws.com/rds-downloads/rds-ca-bundle-us-gov-west-1.pem"
                    }
#Install root RDS Certificate
$certpath = Join-Path -Path $env:TEMP -ChildPath "root.pem"
if(Test-Path $certpath)
{
    Remove-Item -Path $certpath -Force
}
$webclient = New-Object -TypeName System.Net.WebClient
$webclient.DownloadFile($RdsCertificateUrl["root"],$certpath)
$cert = Get-Item -Path $certpath
$cert |Import-Certificate -CertStoreLocation Cert:\LocalMachine\Root

#Install Region Intermediate Certificate
$region = (Invoke-Restmethod -Method Get -Uri http://169.254.169.254/latest/meta-data/placement/availability-zone).Substring(0,$region.Length-1)
$certpath = Join-Path -Path $env:TEMP -ChildPath "$region.pem"
if(Test-Path $certpath)
{
    Remove-Item -Path $certpath -Force
}
$webclient = New-Object -TypeName System.Net.WebClient
$webclient.DownloadFile($RdsCertificateUrl["$region"],$certpath)
$cert = Get-ChildItem -Path $certpath
$cert |Import-Certificate -CertStoreLocation Cert:\LocalMachine\CA
