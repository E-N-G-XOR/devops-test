#!/bin/bash

if [ -z "$1" ] || [ $# -ne 1 ]; then
    echo "Must pass candidate name as first parameter with no spaces."
    echo "Usage: ./setup.sh <candidate name>"
    exit 1
fi

CANDIDATE_NAME=$1
TESTER_HOME=$(pwd)

cd $TESTER_HOME/../terraform

rm -rf .terraform

# Setup account
aws-vault exec lw-interview --no-session -- terraform init -backend-config "key=$CANDIDATE_NAME/terraform.tfstate"
aws-vault exec lw-interview --no-session -- terraform apply -var "candidate=$CANDIDATE_NAME"

cd $TESTER_HOME

# Setup repo. Credentials can be obtained from IAM -> terraform user -> Security Credentials -> HTTPS Git Credentials
# Password generally has special characters so can be url encoded
git clone https://terraform-at-537977624843:okG%2FXuziIBNpyqZ3YPdcMd8rYPto%2FthhD67MbPYIkfI%3D@git-codecommit.eu-west-1.amazonaws.com/v1/repos/lw-candidate-test-$CANDIDATE_NAME /tmp/lw-candidate-test-$CANDIDATE_NAME

rsync -av --exclude=tester/ --exclude=.terraform --exclude=.git ../ /tmp/lw-candidate-test-$CANDIDATE_NAME/

cd /tmp/lw-candidate-test-$CANDIDATE_NAME

git add .
git commit -m "Intial Commit"
git push origin master

rm -rf /tmp/lw-candidate-test-$CANDIDATE_NAME

# Fetch password
cd $TESTER_HOME
gpg --import private.key

cd $TESTER_HOME/../terraform

aws-vault exec lw-interview --no-session -- terraform output password | base64 --decode > /tmp/lw-candidate-test-$CANDIDATE_NAME-key
PASSWORD=$(gpg --decrypt /tmp/lw-candidate-test-$CANDIDATE_NAME-key)

rm /tmp/lw-candidate-test-$CANDIDATE_NAME-key

echo "Candidate log details are: "
echo ""
echo "Login URL: https://lw-interview.signin.aws.amazon.com/console"
echo "Username: $CANDIDATE_NAME"
echo "Password: $PASSWORD"
