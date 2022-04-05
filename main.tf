

# Creating Lambda IAM resource
resource "aws_iam_role" "lambda_iam" {

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "revoke_keys_role_policy" {
  role = aws_iam_role.lambda_iam.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*",
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# Creating Lambda resource
resource "aws_lambda_function" "test_lambda" {
  function_name    = var.function_name
  role             = aws_iam_role.lambda_iam.arn
  handler          = "src/${var.handler_name}.lambda_handler"
  runtime          = var.runtime
  timeout          = var.timeout
  filename         = "../src.zip"
  source_code_hash = filebase64sha256("../src.zip")
}

# Creating s3 resource for invoking to lambda function
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_nameA
  acl    = "private"

  tags = {
    Environment = var.environment
  }
}

resource "aws_s3_bucket" "bucketB" {
  bucket = var.bucket_nameB
  acl    = "private"

  tags = {
    Environment = var.environment
  }
}

# Adding S3 bucket as trigger to my lambda and giving the permissions
resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
  bucket = aws_s3_bucket.bucket.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.test_lambda.arn
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]

  }
}
resource "aws_lambda_permission" "test" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${aws_s3_bucket.bucket.id}"
}

#create user A

resource "aws_iam_user" "userA" {
  name = "userA"
}

resource "aws_iam_user_policy" "userAPolicy" {
  name = "test"
  user = aws_iam_user.userA.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
            "s3:GetObject",
            "s3:GetBucketLocation",
            "s3:ListBucket"
            "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
          "arn:aws:s3:::bucketA/*",
          "arn:aws:s3:::bucketA"
      ]
    }
  ]
}
EOF
}

#create user B

resource "aws_iam_user" "userB" {
  name = "userB"
}

resource "aws_iam_user_policy" "userBPolicy" {
  name = "test"
  user = aws_iam_user.userB.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
            "s3:GetObject",
            "s3:GetBucketLocation",
            "s3:ListBucket"
            "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
          "arn:aws:s3:::bucketB/*",
          "arn:aws:s3:::bucketB"
      ]
    }
  ]
}
EOF
}