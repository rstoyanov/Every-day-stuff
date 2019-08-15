# Change permissions of .pem file in AWS
chmod 400 LAB-CentOS.pem

# Connect to AWS Machine
ssh -i "LAB-CentOS.pem" centos@ec2-18-221-142-23.us-east-2.compute.amazonaws.com

# Install net-tools including ifconfig
sudo yum install net-tools

# List all IP addresses (ifconfig is depreciated)
ip a

# Play with bash terminal colors: https://www.tecmint.com/customize-bash-colors-terminal-prompt-linux/
PS1="\e[30;0;37m[\u@\h \W]$ "

# Locates C library in /lib related to the specific program like pwd. 
strace -e open pwd

# Checks which username you are logged in with
whoami

# Change user to root
sudo su

# Change user back to non root
sudo su centos

# Create a file without any content
touch testfile

