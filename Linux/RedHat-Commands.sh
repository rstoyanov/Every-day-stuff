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

# Search for a file using find command. It searches interactivelly.
find . -name "rado"
sudo find / -name "misha"

# Search using locate command. It uses a db to cache its results. The DB should be updated using updatedb.
sudo yum install mlocate
sudo updatedb
locate misha

# Change password. If you are root you can specify account on whitch password to be changed. passwd rado
passwd

# Create nine files with one command.
touch abc{1..9}

# Remove multiple files with one command
rm abc* --force

# List files with specific name
ls abc* -ltr

# List all matching files and directories which match the letters in []
ls -l *[xz]*

# List all files which match the string
ls -l *xy*

# List files which start with unknown letter but have other letters inside their name.
ls -l ?bc*

# Create a soft link
ln -s /home/rado/testfile

# Create a hard link (Hard links work only within the same partition)
ln /home/rado/testfile

# Removes a directory and its subdirectories
rm -r testdir

# Remove permissions from a file (user, group, others, all)
chmod u-w testfile
chmod g-rw testfile
chmod o-rwx testfile
chmod a-r testfile

# Give permissions to a file (user, group, all)
chmod u+rwx
chmod g+rw
chmod o+r
chmod a+r testfile

# Change ownership of a file
sudo chown username testfile

# Change group ownership of a file
sudo chgrp groupname testfile

# Help commands
whatis ssh
man ssh
ssh --help

# Write output to a file (Overwrites the last file content!!!)
echo "Write some text inside" > testfile

# Append text to a file
echo "Write some more text inside" >> testfile

# Output a result of a command to a file
ls -ltr > resultfile
