resource "aws_ecs_task_definition" "web1" {
  family                = "service"
  container_definitions = "${file("./task-def/web1-service.json")}"

  volume {
    name      = "web1-storage"
    host_path = "/ecs/web1-service-storage"
  }

#  placement_constraints {
#    type       = "memberOf"
#    expression = "attribute:ecs.availability-zone in [eu-west-1a, eu-west-1b]"
#  }
}
