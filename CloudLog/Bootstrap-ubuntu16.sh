sudo apt-get update -y
sudo apt-get install wget -y
REGION=$(wget -q -O - http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}')
sudo curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O
sudo chmod +x ./awslogs-agent-setup.py
sudo apt-get install python -y
#sudo apt-get install python-pip -y
sudo python ./awslogs-agent-setup.py --region $REGION --non-interactive --configfile "https://raw.githubusercontent.com/BrokenFlame/AWS/master/CloudLog/BasicConfig"
curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O https://raw.githubusercontent.com/BrokenFlame/AWS/master/CloudLog/awslogs.service
cd /etc/systemd/system
wget https://raw.githubusercontent.com/BrokenFlame/AWS/master/CloudLog/awslogs.service
sudo chmod +X /etc/systemd/system/awslogs.service
sudo systemctl start awslogs.service
