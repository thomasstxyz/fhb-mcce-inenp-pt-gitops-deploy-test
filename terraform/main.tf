terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.26.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.0.1"
    }
  }
  required_version = ">= 1.1.0"

  cloud {
    organization = "2110781014"

    workspaces {
      name = "tmcsp-gitops-deploy"
    }
  }
}
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
# Archive a file to be used with Lambda using consistent file mode
data "archive_file" "lambda_deleteTodo" {
  type             = "zip"
  source_file      = "${path.module}/../lambda/functions/deleteTodo/index.js"
  output_file_mode = "0666"
  output_path      = "${path.module}/files/lambda-deleteTodo.js.zip"
}

data "archive_file" "lambda_getTodos" {
  type             = "zip"
  source_file      = "${path.module}/../lambda/functions/getTodos/index.js"
  output_file_mode = "0666"
  output_path      = "${path.module}/files/lambda-getTodos.js.zip"
}

data "archive_file" "lambda_updateTodo" {
  type             = "zip"
  source_file      = "${path.module}/../lambda/functions/updateTodo/index.js"
  output_file_mode = "0666"
  output_path      = "${path.module}/files/lambda-updateTodo.js.zip"
}

# iam role needed by lambda
data "aws_iam_role" "LabRole" {
  name = "LabRole"
}

resource "aws_lambda_function" "deleteTodo" {
  filename      = data.archive_file.lambda_deleteTodo.output_path
  function_name = "deleteTodo-function"
  role          = data.aws_iam_role.LabRole.arn
  handler       = "index.handler"

  source_code_hash = filebase64sha256(data.archive_file.lambda_deleteTodo.output_path)

  runtime = "nodejs16.x"

  environment {
    variables = {
      app = "todo"
    }
  }

  depends_on = [
    data.archive_file.lambda_deleteTodo
  ]
}

resource "aws_lambda_function_url" "deleteTodo" {
  function_name      = aws_lambda_function.deleteTodo.function_name
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

resource "aws_lambda_function" "getTodos" {
  filename      = data.archive_file.lambda_getTodos.output_path
  function_name = "getTodos-function"
  role          = data.aws_iam_role.LabRole.arn
  handler       = "index.handler"

  source_code_hash = filebase64sha256(data.archive_file.lambda_getTodos.output_path)

  runtime = "nodejs16.x"

  environment {
    variables = {
      app = "todo"
    }
  }

  depends_on = [
    data.archive_file.lambda_getTodos
  ]
}

resource "aws_lambda_function_url" "getTodos" {
  function_name      = aws_lambda_function.getTodos.function_name
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

resource "aws_lambda_function" "updateTodo" {
  filename      = data.archive_file.lambda_updateTodo.output_path
  function_name = "updateTodo-function"
  role          = data.aws_iam_role.LabRole.arn
  handler       = "index.handler"

  source_code_hash = filebase64sha256(data.archive_file.lambda_updateTodo.output_path)

  runtime = "nodejs16.x"

  environment {
    variables = {
      app = "todo"
    }
  }

  depends_on = [
    data.archive_file.lambda_updateTodo
  ]
}

resource "aws_lambda_function_url" "updateTodo" {
  function_name      = aws_lambda_function.updateTodo.function_name
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

output "url_deleteTodo" {
  value = aws_lambda_function_url.deleteTodo.function_url
}
output "url_getTodo" {
  value = aws_lambda_function_url.getTodos.function_url
}
output "url_updateTodo" {
  value = aws_lambda_function_url.updateTodo.function_url
}
resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "todos"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "dynamodb-table-1"
    app = "todo"
  }
}
