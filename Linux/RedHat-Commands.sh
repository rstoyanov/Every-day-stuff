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

# Replace content of a file with another content
sed 's/OldContnt/NewContent/g' tesftile




