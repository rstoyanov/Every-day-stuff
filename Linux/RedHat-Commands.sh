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
chown username testfile

# Change group ownership of a file
chgrp groupname testfile

# Change username and group ownerwhip of a file with one command
chown username:group testfile

# Help commands
whatis ssh
man ssh
ssh --help

# Write output to a file (Overwrites the latest file content!!!)
echo "Write some text inside" > testfile

# Append text to a file
echo "Write some more text inside" >> testfile

# Outputs the result to a file as well as it prints it to the screen (Overwrites the latest file content)
echo "This is done by using tee command" | tee testfile2

# Append text to a file using tee -a command
echo "This is appended text done by using tee -a command" | tee -a testfile2

# Output a result of a command to a file
ls -ltr > resultfile

# Returns count of bytes, characters, words, etc. -c -m -w
wc -c testfile2

# A command that returns the same output like ls -l
ll

# Get results one page at a time
ls -ltr | more
more testfile 

# Displays content from a file
more testfile # Gets content one page at a time
head testfile # Gets top lines
less testfile # Allow you to scroll one line at a time
cat testfile # Prints the whole content
tail testfile # Prints last lines 


head -10 testfile # Displays 10 rows on the top
tail -20 testfile # Displays 20 rows on the bottom
tail -f testile # Displays in real time (--follow)

# Shows cutted text from a file
cut -c1 testfile # displays firt letters per line from a file
cut -c1-2 testfile # returns the range of letters

# Shows specific column from a file
awk '{print $1}' testfile # Shows the first column
awk '{print $2}' testfile # Shows the second column

# Sorts the output
awk '{print $1}' | sort

# Displays only uniq content
awk '{print $1}' | sort | uniq # It has to be sorted firts, otherwise uniq doesn't work

# Compare two files 
diff testfile testfile2 # Compares words
cmp testfile testfile2 # Compares bytes

# Archive files in tar
tar -cvf testfile.tar /home/centos/abc* # archives all files starting with abc

# Extract from tar archive
tar -xvf testfile.tar

# Compress tar files
gzip testfile.tar

# Decompress files 
gzip -d testfile.tar.gz

# View the content of a zipped text file
zcat testfile.gz

# Combine 2 files in 1
cat file1 file2 > newfile

# Split files 
split -l 2 newfile sepfile # Exports each 2 lines to a separate file

# Replace content of a file with another content. # -i is used if you want to replace the content in the file. Without -i it only shows the replaced content on the screen.
sed -i 's/OldContnt/NewContent/g' tesftile # g at the and stands for "global" and replaces the text everywhere in the file

# Removes the old content from a file.
sed -i 's/OldContnt//g' tesftile # -i is used if you want to replace the content in the file. Without -i it only shows the replaced content on the screen.


# Deletes the whole line containting specified keyword
sed -i '/keyword/d' testfile

# Deletes empty lines
sed -i '/^$/d' testfile

# Removes the first line from the file
sed -i '1d' testfile
sed -i '1d,2d' testfile # Removes first 2 lines

# Replaces tab with space
sed -i '/\t/ /g' testfile

# Adds empty line after each line of text
sed -i G testfile

# Replaces content except 1st row
sed '1!s/Stoy/ /g' testfile

# Replace text in vi
:%s/Rado/Misha

# USER AND GROUP MANAGEMENT

# Create a user
useradd -G users,admins -s /bin/bash -c "Radostin Stoyanov" -m -d /home/rstoyanov rstoyanov 

# Modify user. Append user to another groups
usermod -a -G powerusers,jirausers rstoyanov

# Check user existance
cat /etc/shadow
cat /etc/passwd
groups rstoyanov

# Delete a uses and delete his home directory as well
userdel -r rstoyanov # -r deletes it home directory

# Create a group
groupadd powerusers

# Check what groups exist in the system
cat /etc/group | grep powerusers

# Delete a group
groupdel powerusers

# SWITCH USERS AND SUDO ACCESS

# Switch to another user
sudo su rstoyanov

# Switch to root
sudo su -

# Modigying sudoers file
sudo visudo

# MONITOR USERS

# Loggedon users
users

# Check who is logged in to the system
who -a

# Who is logged in whith more details
w

# Who using fineger. Provides some more details
sudo yum install finger -y # It is not preinstalled, so we need to install it first.
finger

# Information about specific user
id rstoyanov

# Check last logins
last | more

# Extract only uniq users that have been logged in
last | awk '{print $1}' | sort | uniq

# TALKING TO USERS

# Write message to the wall
wall # Hit Enter

Please logoff. This system is going down for maintenance

-- Rado # Hit Ctrl+D

# Write message in realtime to a specifig logged on user
write rstoyanov # Hit Enter

Hey Rado, please stop your script, because the server is running out of resources. 

-- SysAdmin # Hit Ctrl+D

# SYSTEM UTILITY COMMANDS

date # displays the date and time
date -s "Sun Aug 18 22:40 EEST 2019" # Setting date
uptime # server uptime + logged on users
hostname # hostname of the server
uname -a #  tells you if you are running Linux or other *nix system and some details
which "command" # tells you which command in which file is located
cal # returns the calendar for this month
cal 12 1985 # returns December 1985 :)
cal 2019 # all months of 2019  
bc # basic calculator in the terminal

# PROCESSES AND JOBS

# Check running processes
ps -ef

# Start a service
systemctl start ntpd 

# Stop a service
systemctl stop ntpd

# Enable autostart of a service
systemctl enable ntpd 

# Check the status of a service
systemctl status ntpd 

# See all services
systemctl list-units --type service

sytemctl list-units | grep httpd
systemctl list-units --type mount

# Service start log
journalctl -xe

# Monitor resources
top 
top -h # Shows the usage of top
top -u rstoyanov # Shows user specific processes
top -d 10 # Delays with 10 seconds

# Kill a process
kill processID 

# Working with cron jobs
crontab -l # lists all cron jons
crontab -e # enters in edit mode

# Crontab time intervals
# minute          0-59 / *
# hour            0-23 / *
# day of month    1-31 / *
# month           1-12 / *
# day of week     0-7 / *

# In this file is the information about the time of execution of daily, weekly, monthly jobs
cat /etc/anacrontab 

# For hourly crontab schedule
cat /etc/cron.d/0hourly

# PROCESS MANAGEMENT











