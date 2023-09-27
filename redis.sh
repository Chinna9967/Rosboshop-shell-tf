#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
# /home/centos/shellscript-logs/script-name-date.log
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ];
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ];
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOGFILE

VALIDATE $? "Setting up NPM Source"

yum install nodejs -y &>>$LOGFILE

VALIDATE $? "Installing NodeJS"

#once the user is created, if you run this script 2nd time
# this command will defnitely fail
# IMPROVEMENT: first check the user already exist or not, if not exist then create
useradd roboshop &>>$LOGFILE
if id "roboshop" &>/dev/null; then
    echo "User 'roboshop' already exists."
else
    echo "User 'roboshop' does not exist. Creating..."
    sudo useradd roboshop
    echo "User 'roboshop' created successfully."
fi

#write a condition to check directory already exist or not
mkdir /app &>>$LOGFILE
directory="/app"

# Check if the directory exists
if [ -d "$directory" ]; then
    echo "Directory '$directory' already exists."
else
    echo "Directory '$directory' does not exist. Creating..."
    mkdir -p "$directory"
    echo "Directory '$directory' created successfully."
fi

yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>$LOGFILE

VALIDATE $? "Installing redis repo"

yum module enable redis:remi-6.2 -y &>>$LOGFILE

VALIDATE $? "Enabling redis 6.2"

yum install redis -y &>>$LOGFILE

VALIDATE $? "Installing redis 6.2"

sed -i 's/127.0.0.1/0.0.0.0/g'  /etc/redis.conf /etc/redis/redis.conf &>>$LOGFILE

VALIDATE $? "Allowing Remote connections to redis"

systemctl enable redis &>>$LOGFILE

VALIDATE $? "Enabling redis"

systemctl start redis &>>$LOGFILE

VALIDATE $? "Starting redis "