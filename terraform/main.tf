module "vpc" {
  source             = "./modules/vpc"
  name               = "main-${var.candidate}"
  cidr               = "10.0.0.0/16"
  azs                = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
  Managed     = "terraform"
  Environment = "${var.environment}"
}

}

module "ecs" {
  source = "./modules/ecs"

  name    = "${var.candidate}-candidate-test"
  vpc_id  = "${module.vpc.vpc_id}"
  subnets = "${module.vpc.private_subnets}"
}

resource "aws_iam_user" "candidate" {
 name = "${var.candidate}"
 path          = "/"
 force_destroy = true
}

resource "aws_iam_user_policy_attachment" "candidate" {
 user       = "${aws_iam_user.candidate.name}"
 policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_user_login_profile" "candidate" {
 user                    = "${aws_iam_user.candidate.name}"
 password_reset_required = false
 pgp_key                 = "mQENBFzAercBCACr2UtKuFh+NvdvW64/yeYHHaLXNzVG089tlClUHld31Ab/w6xWYcADq0zPrnYYIz9w3MJIwbxr+CXTtywNkdbRjVMyp5odrFNXUVg5mXIVkmI7IZz7KsDSY+JhztbGlpTcgw3r0DU29KtiyPk8uj0sZcZNu+oTGpDa+b3/+SklEdwMQ1AwKIxYe1qyBLnKRMCN84D5SyJHXxqcvCv7wPwtaFvsBJ8MmXAMOU/j0sg2ziMMpA/wEfPLXK3ZkDOQgpghUZjR95olChMGaej98UXmO6gOcSMuktjfI0huSvAHQYDNMNxYQXszvtUi3JhHElItSVPAck5YjSTxfwQCu9ytABEBAAG0K0xpZmV3b3JrcyBEZXZvcHMgVGVzdCA8aW5mcmFAbGlmZXdvcmtzLmNvbT6JAVQEEwEIAD4WIQQElsrDagAb4qZ5RsMAZldXMTnjHgUCXMB6twIbAwUJA8JnAAULCQgHAgYVCgkICwIEFgIDAQIeAQIXgAAKCRAAZldXMTnjHn7NB/9Qf56wUM3F1i22rc4BrpdNQUobD61EgVSDY9I0Lv+BaUbSGsAc0MAw1gnGiNGuMR7qhjExunDWrp8nyySgVuPrmRaF7q/hFD9fm4DTrfN90I5Gd2LDxxmhud2xAwTDCJmvz3CDRDATN6ECRcMTv24Yp4jzdH6NSeN1O+rdCPMp43YX3zoQqtpMC/TS7IiIkx5xAuV8u/MQlNDMCRUmDOyqHgjaNtF8m2Gq+uiRAF+TFlWKJWnuyi8Zixxj4JMKyUxDZm4epXCOquhiSgUPY44cJEgrYZEM8A3V27nS7nmO0kia9Md88g4FXrbmJOIYQ4xBmsJGu+Sm1I4NxFgwIgh0uQENBFzAercBCAC+3ASfAdNDd5Ay7u5nRCxm6t8OIr6hRtDDjFIJhnd4uqiWmtyQmv/CGaXu4/xybofoBEvM0N8ZYByV5Ya6uN1B2lH0kJypiTwFqPEIssIODDTSsyfGEhbp+76iLeLrVtYj6wGadFa43P4jfoHI6XXFIX7fkyvlcIsLb4eGEbphTAP4cUu8KPLsD0AQb+cqycRP848G8oTo7GFana09zq37JbmFnM8aCyD75iQzKPTAoGN2rdIwjxBKpEhL86HUFTkCHhBlm0w7Insth8pfWVurScwdADHQGlaZNcqCj5CNLn6SuKydrPSbyR0/FPDP7u9yMz0qrua/UNxbMDQCrGVlABEBAAGJATwEGAEIACYWIQQElsrDagAb4qZ5RsMAZldXMTnjHgUCXMB6twIbDAUJA8JnAAAKCRAAZldXMTnjHs4xB/42QlRB2zgyv1mCBtf4Y3eLcpey6zUa9ScOP0K1ry2lxgP8dFz/TQ8YifHdMW7SQeVjmWtwbYDZ4uiqBhlytiNs0zZMYCggFA2HtkgAIWs50I2aQ6WCHC20jF53gB23ONUrzzbjdQ2wbww1yhVUQjHArCI8j67mzEUrqKDJNrPQo0VOwsUXF/QSerBFvQHQaptYt4hP8YGkmcwBkV5VNA45X09qMoDlNisP1+auamfFpG19bPFOVqsIt/zhVhxDh2+9BWsxmDJ8FMsk79cPCKrYkiJTX6fEcAgokyA8weicoJNicrNqj/39BqkP5q0GTU+tzaH5tA1+eiEIRtUT3zLy"
}

resource "aws_codecommit_repository" "candidate" {
  repository_name  = "lw-candidate-test-${var.candidate}"
  description      = "Lifeworks devops test for ${var.candidate}"
}

resource "aws_cloudtrail" "candidate_test" {
  name                          = "lw-trail-candidate-test-${var.candidate}"
  s3_bucket_name                = "${aws_s3_bucket.lw_cloudtrail_candidate_test.id}"
  include_global_service_events = false
}

resource "aws_s3_bucket" "lw_cloudtrail_candidate_test" {
  bucket        = "lw-cloudtrail-candidate-test-${var.candidate}"
  force_destroy = true

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::lw-cloudtrail-candidate-test-${var.candidate}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::lw-cloudtrail-candidate-test-${var.candidate}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}
