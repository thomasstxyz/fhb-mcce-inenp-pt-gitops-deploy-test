resource "aws_s3_bucket" "todoApp" {
  bucket = "tmcsp-team-j-todo-app"
}

resource "aws_s3_bucket_acl" "todoApp" {
  bucket = aws_s3_bucket.todoApp.id
  acl    = "private"
}

resource "aws_s3_bucket_website_configuration" "todoApp" {
  bucket = aws_s3_bucket.todoApp.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "todoApp" {
  bucket = aws_s3_bucket.todoApp.id
  policy = data.aws_iam_policy_document.todoApp.json
}

data "aws_iam_policy_document" "todoApp" {
  statement {
    sid = "Add permission"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.todoApp.bucket}/*",
    ]
  }
}

output "bucket_website_url" {
  value = aws_s3_bucket_website_configuration.todoApp.website_endpoint
}
