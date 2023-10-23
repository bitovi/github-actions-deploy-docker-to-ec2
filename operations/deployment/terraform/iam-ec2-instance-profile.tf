resource "aws_iam_role" "ec2_role" {
  count = var.ec2_iam_instance_profile != "" ? 0 : 1
  name = var.aws_resource_identifier
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# attach a policy to allow cloudwatch access
resource "aws_iam_policy" "cloudwatch" {
  count = var.ec2_iam_instance_profile != "" ? 0 : 1
  name = var.aws_resource_identifier
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cloudwatch_attach" {
  count      = var.ec2_iam_instance_profile != "" ? 0 : 1
  role       = aws_iam_role.ec2_role[0].name
  policy_arn = aws_iam_policy.cloudwatch[0].arn
}