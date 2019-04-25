README for testers
==================

A little setup script has been provided to bootstrap the lw-interview account
for a new candidate.

To set up a new candidate do the following:

1. Ensure you have aws-vault installed and have added the keys for the
   lw-interview account with the profile name lw-interview.

    aws-vault add lw-interview

2. Run the terraform for the candidate and setup their CodeCommit repo by
   supplying the name of the candidate to the setup script. Please keep it short
   and don't reveal the candidates full name. Recommend first name and initial
   of surname eg. jamiel

    ./setup.sh <candidate name>

3. This will create an IAM user on the lw-interview account. And output the
   login details to the terminal. Give the details to the candidate and tell
   them they can find the test intructions in the git repository in AWS
   CodeCommit inside the account. The repository is called
   lw-candidate-test-<candidate name>. The test will start as soon as they login
   to the AWS console.

You may have noticed the private key and git passwords are in plain text in this
repo which is obviously not best practice. That's because it would have added too
many additional steps to the setup of this test to introduce secrets management,
and as the we don't really care about this content or the lw-interview account
decided to keep it simple.

Marking the test
----------------

Once the candidate submits their test, you will be able to see and test their
repo using CodeCommit in the lw-interview account.

If you need to run their terraform be sure to use their name as the config key:

    aws-vault exec --no-session lw-interview -- terraform init -backend-config 'key=<candidate username>/terraform.tfstate'
    aws-vault exec --no-session lw-interview -- terraform plan -var 'candidate=<candidate username>'

When you are done, you can destroy all their resources using:

    aws-vault exec --no-session lw-interview -- terraform init -backend-config 'key=<candidate username>/terraform.tfstate'
    aws-vault exec --no-session lw-interview -- terraform destroy -var 'candidate=<candidate username>'
