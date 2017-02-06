curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O
sudo apt-get install python2.7 -y
sudo apt-get install python-pip -y
sudo python ./awslogs-agent-setup.py --region eu-west-1 --non-interactive --configfile="https://raw.githubusercontent.com/BrokenFlame/AWS/master/CloudLog/BasicConfig"
sudo chkconfig awslogs on
sudo service awslogs start
