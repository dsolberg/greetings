#!/bin/bash
export REGION=us-east-1
export AWSBIN=$(which aws)
export JQBIN=$(which jq)
if ! [ -x ${AWSBIN} ]
then
 echo "You need to install the AWS CLI tools"
 exit
fi
if ! [ -x ${JQBIN} ]
then
 echo "You need to install JQ"
 exit
fi

echo "Creating the Greetings API Stack"
${AWSBIN} cloudformation create-stack --region ${REGION} --capabilities CAPABILITY_IAM --stack-name GreetingsAPIStack --template-body file://./greetings-stack.yml

echo "Waiting for stack to complete building"
${AWSBIN} cloudformation wait stack-create-complete --region ${REGION} --stack-name GreetingsAPIStack

echo "Fetching RestApiId from created stack"
export RESTAPI=`${AWSBIN} cloudformation describe-stack-resources --region ${REGION} --stack-name GreetingsAPIStack |${JQBIN} '.StackResources[] | select(.LogicalResourceId==("RestApi"))'|${JQBIN} '.PhysicalResourceId'|cut -d\" -f2`

echo -e "Testing latest API with:\ncurl https://${RESTAPI}.execute-api.${REGION}.amazonaws.com/LATEST/greeting"
echo "Result:"
curl https://${RESTAPI}.execute-api.${REGION}.amazonaws.com/LATEST/greeting
echo -e "\n"
echo -e "Testing staged API with name feature:\ncurl https://${RESTAPI}.execute-api.${REGION}.amazonaws.com/Staging/greeting?name=Darion"
echo "Result:"
curl https://${RESTAPI}.execute-api.${REGION}.amazonaws.com/Staging/greeting?name=Darion
echo -e "\n"

