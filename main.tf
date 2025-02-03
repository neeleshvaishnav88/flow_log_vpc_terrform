# create vpc 
resource "aws_vpc" "vpc_1" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.vpc_name}"
  }
}
# Creating flow log
 resource "aws_flow_log" "vpc_floW_log" {
   iam_role_arn = aws_iam_role.flow_log_role.arn
   log_destination = aws_cloudwatch_log_group.vpc_log_group.arn
   traffic_type = "ALL"
   vpc_id = aws_vpc.vpc_1.id
   log_destination_type = "cloud-watch-logs"
 }
 resource "aws_cloudwatch_log_group" "vpc_log_group" {
   name = "vpc_log_group"
   tags = {
     Environment ="development"
   }
 }
 resource "aws_iam_role" "flow_log_role" {
   name = "flow_log_role"
   assume_role_policy =  jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "VPCFlowLogsAccess",
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })
}
resource "aws_iam_policy" "flow_log_policy" {
  name = "flow_log_policy"
  description = "policy for vpc"
  policy = jsonencode({
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

resource "aws_iam_role_policy_attachment" "flow_log_policy_attachment" {
  role = aws_iam_role.flow_log_role.name
  policy_arn = aws_iam_policy.flow_log_policy.arn
}