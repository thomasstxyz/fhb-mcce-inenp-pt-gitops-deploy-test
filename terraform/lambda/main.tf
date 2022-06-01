# Archive a file to be used with Lambda using consistent file mode
data "archive_file" "lambda_deleteTodo" {
  type             = "zip"
  source_file      = "${path.module}/../../lambda/functions/deleteTodo/index.js"
  output_file_mode = "0666"
  output_path      = "${path.module}/files/lambda-deleteTodo.js.zip"
}

data "archive_file" "lambda_getTodos" {
  type             = "zip"
  source_file      = "${path.module}/../../lambda/functions/getTodos/index.js"
  output_file_mode = "0666"
  output_path      = "${path.module}/files/lambda-getTodos.js.zip"
}

data "archive_file" "lambda_updateTodo" {
  type             = "zip"
  source_file      = "${path.module}/../../lambda/functions/updateTodo/index.js"
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
