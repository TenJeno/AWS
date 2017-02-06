sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install libwww-perl libdatetime-perl wget unzip -y
cd /opt/
sudo wget http://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.1.zip
sudo unzip CloudWatchMonitoringScripts-1.2.1.zip
sudo rm CloudWatchMonitoringScripts-1.2.1.zip
cd aws-scripts-mon
sudo touch /etc/cron.d/cloudwatch-monitor
sudo chmod 7777 /etc/cron.d/cloudwatch-monitor
sudo echo "*/1 * * * * root /opt/aws-scripts-mon/mon-put-instance-data.pl --disk-space-avail --disk-path=/ --disk-path=/var --from-cron" > /etc/cron.d/cloudwatch-monitor
sudo chmod 0644 /etc/cron.d/cloudwatch-monitor
sudo /etc/init.d/cron restart
