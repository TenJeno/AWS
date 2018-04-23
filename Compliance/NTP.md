# Time Synchronisation 

## Introduction
Synchronising the time across multiple AWS Services and Compute Resources within AWS is increasingly important for both security and auditing purposes.  AWS Services except for EC2 Virtual Machines are automatically synchronised with the Amazon Time Sync Service, irrespective of geographic location.

Amazon’s Time Service utilizes a number of redundant sateliteconnected and atomic reference clocks in AWS regions to deliver current time readings for the Universal Time Coordinate UTC. The service has a low variance in reference time and automatically compensates for the leap second though time smoothing.

For any system which falls under GPSoC, PCI DSS and HIPAA it is mandatory for Auditing/Logging system, including File DateTime Stamps to be synchronised to a Stratum 2 or Stratum 3 Time Server. 

## Implementation:
It is recommended that all services use UTC for Auditing, Logging and Encryption.  As such it is normal practice for servers taking in part in multiregional application to be configured to use UTC. However, in some regions this practice may not be desirable, and the local time set in the Virtual Machines Time Settings. However, this should be avoided where possible.

To ensure that EC2 instances can communicate with the VPC NTP Service open UDP port 123 and well as the port range UDP 1024-65535 in both direction to 169.254.169.123.

### Linux 

For Linux, based systems it is recommended that chrony is used, instead of the ntpd. You may use the example configuration below to configure chrony:

#### RedHat/CentOS

`sudo yum erase ntp*`

`sudo yum install chrony`

`echo “server 169.254.169.123 prefer iburst”  >> /etc/chrony.conf`

`sudo service chronyd start`

`sudo chkconfig chronyd on`

### Ubuntu

`sudo apt install chrony`

`server 169.254.169.123 prefer iburst  >> /etc/chrony.conf`

`sudo /etc/init.d/chrony restart`

*Check Config*

`chronyc sources -v`

`chronyc tracking`

### Windows

On Windows Server 2008 and later you may use the following command to configure the NTP Server to use the AWS Time Server.

`w32tm /config /manualpeerlist:169.254.169.123 /syncfromflags:manual /update`

`W32tm /resync /force`

`w32tm /query /configuration`

Alternately you may use, use the Set-NTP.ps1 function available at https://gallery.technet.microsoft.com/scriptcenter/Set-NTP-16a97b00. The Powershell to use this function is: 

`Set-NTP.ps1 -url 169.254.169.123`
