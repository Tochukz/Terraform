data "aws_iam_policy_document" "assume_task_policy_doc" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "ECSTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_task_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "policy_attach" {
  role = aws_iam_role.ecs_task_role.name
  # This is an AWS managed policy. Search fo it at IAM console -> Access Management -> Policies
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
