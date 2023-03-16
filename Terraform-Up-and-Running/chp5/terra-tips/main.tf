provider "aws" {
  region = "eu-west-2" 
}

data "aws_iam_policy_document" "ec2_readonly" {
  statement {
    effect = "Allow"
    actions = ["ec2:Describe*"]
    resources = ["*"]
  }
}

# creates users with names: john-0, john-1, john-2 
resource "aws_iam_user" "john_users" {
  count = 3
  name = "john-${count.index}"
}

# creates a user for each element of the user_names array
resource "aws_iam_user" "array_of_users" {
  count  = length(var.user_names)
  name = element(var.user_names, count.index)
}

resource "aws_iam_policy" "ec2_readonly" {
  name = "ec2-read-only"
  policy = "${data.aws_iam_policy_document.ec2_readonly.json}"
}

resource "aws_iam_policy_attachment" "ec2_access" {
  name = "iam-policy-attachment"
  count = "${length(var.user_names)}"
  users  = [ element(aws_iam_user.array_of_users.*.name, count.index) ]
  policy_arn = "${aws_iam_policy.ec2_readonly.arn}"
}

resource "aws_s3_bucket" "website_bucket" {
  bucket = "tochukwu.xyz.terra-tip-bucket"
  count = "${var.add_bucket}"
}