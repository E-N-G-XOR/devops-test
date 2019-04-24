resource "aws_codecommit_repository" "candidate" {
  repository_name  = "lw-candidate-test-${var.candidate}"
  description      = "Lifeworks devops test for ${var.candidate}"
}
