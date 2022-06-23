terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.16.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.2.0"
    }
  }
  required_version = ">= 1.1.0"

  cloud {
    organization = "2110781014"

    workspaces {
      name = "tmcsp-gitops-deploy-test"
    }
  }
}
provider "aws" {
  # Configuration options
  region = "us-east-1"
}

resource "aws_s3_bucket" "todoAppTest" {
  bucket = "tmcsp-team-j-todo-app-test"
}

resource "aws_s3_bucket_acl" "todoAppTest" {
  bucket = aws_s3_bucket.todoAppTest.id
  acl    = "private"
}

resource "aws_s3_bucket_website_configuration" "todoAppTest" {
  bucket = aws_s3_bucket.todoAppTest.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "todoAppTest" {
  bucket = aws_s3_bucket.todoAppTest.id
  policy = data.aws_iam_policy_document.todoAppTest.json
}

data "aws_iam_policy_document" "todoAppTest" {
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
      "arn:aws:s3:::${aws_s3_bucket.todoAppTest.bucket}/*",
    ]
  }
}

output "bucket_website_url" {
  value = "http://${aws_s3_bucket_website_configuration.todoAppTest.website_endpoint}"
}
# Archive a file to be used with Lambda using consistent file mode
data "archive_file" "lambda_deleteTodoTest" {
  type             = "zip"
  source_file      = "${path.module}/lambda/functions/deleteTodoTest/index.js"
  output_file_mode = "0666"
  output_path      = "${path.module}/files/lambda-deleteTodoTest.js.zip"
}

data "archive_file" "lambda_getTodosTest" {
  type             = "zip"
  source_file      = "${path.module}/lambda/functions/getTodosTest/index.js"
  output_file_mode = "0666"
  output_path      = "${path.module}/files/lambda-getTodosTest.js.zip"
}

data "archive_file" "lambda_updateTodoTest" {
  type             = "zip"
  source_file      = "${path.module}/lambda/functions/updateTodoTest/index.js"
  output_file_mode = "0666"
  output_path      = "${path.module}/files/lambda-updateTodoTest.js.zip"
}

# iam role needed by lambda
data "aws_iam_role" "LabRole" {
  name = "LabRole"
}

resource "aws_lambda_function" "deleteTodoTest" {
  filename      = data.archive_file.lambda_deleteTodoTest.output_path
  function_name = "deleteTodoTest-function"
  role          = data.aws_iam_role.LabRole.arn
  handler       = "index.handler"

  source_code_hash = filebase64sha256(data.archive_file.lambda_deleteTodoTest.output_path)

  runtime = "nodejs16.x"

  environment {
    variables = {
      app = "todo"
    }
  }

  depends_on = [
    data.archive_file.lambda_deleteTodoTest
  ]
}

resource "aws_lambda_function_url" "deleteTodoTest" {
  function_name      = aws_lambda_function.deleteTodoTest.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = false
    allow_origins     = ["*"]
    allow_methods     = ["POST"]
    allow_headers     = ["*"]
    expose_headers    = ["access-control-allow-origin"]
    max_age           = 86400
  }
}

resource "aws_lambda_function" "getTodosTest" {
  filename      = data.archive_file.lambda_getTodosTest.output_path
  function_name = "getTodosTest-function"
  role          = data.aws_iam_role.LabRole.arn
  handler       = "index.handler"

  source_code_hash = filebase64sha256(data.archive_file.lambda_getTodosTest.output_path)

  runtime = "nodejs16.x"

  environment {
    variables = {
      app = "todo"
    }
  }

  depends_on = [
    data.archive_file.lambda_getTodosTest
  ]
}

resource "aws_lambda_function_url" "getTodosTest" {
  function_name      = aws_lambda_function.getTodosTest.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = false
    allow_origins     = ["*"]
    allow_methods     = ["GET"]
    allow_headers     = ["*"]
    expose_headers    = ["access-control-allow-origin"]
    max_age           = 86400
  }
}

resource "aws_lambda_function" "updateTodoTest" {
  filename      = data.archive_file.lambda_updateTodoTest.output_path
  function_name = "updateTodoTest-function"
  role          = data.aws_iam_role.LabRole.arn
  handler       = "index.handler"

  source_code_hash = filebase64sha256(data.archive_file.lambda_updateTodoTest.output_path)

  runtime = "nodejs16.x"

  environment {
    variables = {
      app = "todo"
    }
  }

  depends_on = [
    data.archive_file.lambda_updateTodoTest
  ]
}

resource "aws_lambda_function_url" "updateTodoTest" {
  function_name      = aws_lambda_function.updateTodoTest.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = false
    allow_origins     = ["*"]
    allow_methods     = ["POST"]
    allow_headers     = ["*"]
    expose_headers    = ["access-control-allow-origin"]
    max_age           = 86400
  }
}

output "url_deleteTodoTest" {
  value = aws_lambda_function_url.deleteTodoTest.function_url
}
output "url_getTodosTest" {
  value = aws_lambda_function_url.getTodosTest.function_url
}
output "url_updateTodoTest" {
  value = aws_lambda_function_url.updateTodoTest.function_url
}
resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "todostest"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "dynamodb-table-1-test"
    app  = "todo-test"
  }
}

//
