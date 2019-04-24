DevOps Test
===========

Overview
---------

This repository consists of some terraform to create a vpc and an ECS cluster
in our test account. It also contains a Dockerfile which runs a webserver but is
not currently deployed to our cluster.

We will be looking for you to create a branch of this repository, and then
complete the tasks outlined below. The aim would be to not spend more than 60-90
minutes to complete the task. Feel free to skip some tasks if they are taking
too long.

To track your progress, please commit your work to git after completing
each task.

The terraform inside the terraform folder has already been applied. You can make
your changes using your AWS access keys and running the following inside the
terraform folder:

    terraform init -backend-config 'key=<your username>/terraform.tfstate'
    terraform plan -var 'candidate=<your username>'

Replacing <your username> with the AWS username you were supplied.

Task 1
------

Get this Dockerfile running in the test AWS account behind a publicly accessible
load balancer. This can be done either using EKS or ECS. You should update the
existing terraform to deploy it. No resources should be created manually in the
AWS console with the exception of access keys for the deploy user so that you
can deploy your changes.

*Completion Criteria* Can visit the load balancer URL and shows the output of
the Docker container. The URL can use the hostname assigned by Amazon and does
not need a hosted zone.

Task 2
------

Write a simple script in any language of your preference which does the
following:

```
The script should print each number from 1 to 100 on a new line.

For each multiple of 3, print "Fizz" instead of the number.

For each multiple of 5, print "Buzz" instead of the number.

For numbers which are multiples of both 3 and 5, print "FizzBuzz" instead of the
number.
```

*Completion Criteria* Running the script should output as described above.

Bonus Points: If the script can be deployed as what is executed behind the load
balancer in Task 1 so visiting the load balancer actually runs FizzBuzz.

Task 3
------

To run the Docker container included with this test locally you can execute:

    docker build -t devops-test .
    docker run -d --name devops-test devops-test

To logon the container and get a shell run:

    docker exec -it devops-test /bin/bash

Have a look at what is running on the container, and update this README with the
following information:

*Container Information*

    Container Operating System:

    Container Package Management System:

    Linux Kernel Version:

    Is PHP present on this system?:

    Number of running processes:

    What is the PID of of the primary 'httpd' process?:

    Who has permission to read the file /etc/httpd/conf/httpd.conf?

    How many lines does the file /etc/httpd/httpd.conf consist of?

    How many non-empty lines does the file /etc/httpd/httpd.conf consist of?

Please commit your answers to update this README.

*Completion Criteria* The README.md in your branch should have all the questions
answered.

Task 4
------

Our container needs a secret environmental variable called TEST_SECRET with the
value 'verysecretpassphrase' to be present when the container launches.

Add this secret to the repository and ensure the container can access it.

*Completion Criteria* If we were to connect to your container on AWS,
we should be able to see our secret in the environmental variable TEST_SECRET.

That's it! Please make sure all your work is commited to a branch that is not
master and any terraform is applied. Please make a pull request in AWS Code
Commit for us to review. If you were not able to finish, no worries.

Thanks for taking the test.
