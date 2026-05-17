resource "aws_ecs_cluster" "this" {
  name = "${var.name_prefix}-ecs-${var.environment}"
}

data "aws_iam_policy_document" "ecs_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_execution" {
  name = "${var.name_prefix}-ecs-task-exec-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
}

resource "aws_ecs_task_definition" "this" {
  family = "${var.name_prefix}-${var.service_name}"
  cpu    = var.cpu
  memory = var.memory
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn = aws_iam_role.task_execution.arn
  container_definitions = var.container_definitions
}

resource "aws_ecs_service" "this" {
  name = "${var.name_prefix}-${var.service_name}-svc-${var.environment}"
  cluster = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count = var.desired_count
  launch_type = "FARGATE"
  network_configuration {
    subnets = var.private_subnet_ids
    security_groups = var.security_groups
    assign_public_ip = false
  }
}
