#!/bin/bash

NAMES=("web" "MongoDB" "catalogue" "redis" "user" "MySQL" "cart" "shipping" "RabbitMQ" "Payments" "Dispatch")
INSTANCE_TYPE=""
IMAGE_ID=ami-03265a0778a880afb
SECURITY_GROUP_ID=sg-0815d9222e91b557e
DOMAIN_NAME=kpdigital.online
# if mysql or mongodb instance_type should be t3.micro, for all others it is t2.micro
for i in "${NAMES[@]}"
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

    aws route53 change-resource-record-sets --hosted-zone-id Z03861472RI4AHCM7UM2D --change-batch '
    {
            "Changes": [{
            "Action": "CREATE",
                        "ResourceRecordSet": {
                             "Name": "'$i.$DOMAIN_NAME'",
                             "Type": "A",
                             "TTL": 300,
                             "ResourceRecords": [{ "Value": "'$IP_ADDRESS'"}]
                        }}]
    }'
done

# improvements

# check instance is already created or not
# update route 53 record

