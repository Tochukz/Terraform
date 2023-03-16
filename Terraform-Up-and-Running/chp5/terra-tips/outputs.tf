## First john user ARN
output "first_john_arn" {
  value = "${aws_iam_user.john_users.0.arn}"
}

## All json users ARNs
output "all_john_arns" {
  value = ["${aws_iam_user.john_users.*.arn}"]
}

## All array_of_users ARN 
output "all_users" {
  value = ["${aws_iam_user.array_of_users.*.arn}"]
}