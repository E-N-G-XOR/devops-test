resource "aws_ecr_repository" "repo" {
  name = "lw-repo-${var.name}"
}

resource "aws_ecr_lifecycle_policy" "policy" {
  repository = "${aws_ecr_repository.repo.name}"
  policy     = "${file("${path.module}/templates/lifecycle-policy.json")}"
}
