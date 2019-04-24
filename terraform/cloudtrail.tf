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
