curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O
REGION=$(wget -q -O - http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}')
sudo apt-get install python2.7 -y
sudo apt-get install python-pip -y
sudo python ./awslogs-agent-setup.py --region $REGION --non-interactive --configfile="https://raw.githubusercontent.com/BrokenFlame/AWS/master/CloudLog/BasicConfig"
sudo chkconfig awslogs on
sudo service awslogs start
