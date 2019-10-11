output "repourl" {
  description = "the uri to push images to..."
  value       = "${aws_ecr_repository.repo.repository_url}"
}

output "reponame" {
  description = "The name of the repo created..."
  value       = "${aws_ecr_repository.repo.name}"
}
