#!/bin/bash

NAMES=$@
INSTANCE_TYPE=""
IMAGE_ID=ami-03265a0778a880afb
SECURITY_GROUP_ID=sg-0a9d9f8c0e0e2883c
DOMAIN_NAME=kpdigital.online
HOSTED_ZONE_ID=Z095807329CO3J3GHJQT7
# if mysql or mongodb instance_type should be t3.micro, for all others it is t2.micro
for i in $@
do 
    if [[ $i == "MongoDB" || $i == "MySQL" ]]
    then    
        INSTANCE_TYPE="t3.medium"
    else 
        INSTANCE_TYPE="t2.micro"
    fi
    echo "Creating $i instance"
    IP_ADDRESS=$(aws ec2 run-instances --image-id $IMAGE_ID --instance-type $INSTANCE_TYPE --security-group-ids $SECURITY_GROUP_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" | jq -r '.Instances[].PrivateIpAddress')
    echo "Creating $i instance: $IP_ADDRESS"

    aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch '
    {
            "Changes": [{
            "Action": "CREATE",
                        "ResourceRecordSet": {
                             "Name": "'$i.$DOMAIN_NAME'",
                             "Type": "A",
                             "TTL": 1,
                             "ResourceRecords": [{ "Value": "'$IP_ADDRESS'"}]
                        }}]
    }'
done

# improvements

# check instance is already created or not
# update route 53 record
# check route53 record is already exist, if exist update,otherwise create route53 record

