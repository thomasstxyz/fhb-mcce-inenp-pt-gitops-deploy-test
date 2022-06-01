# Description

This repository contains:

- Lambda functions source in `lambda/functions/`:
    - deleteTodo
    - getTodos
    - updateTodo
- Terraform plans:
    - `terraform/dynamodb/`, which creates the DynamoDB Table.
    - `terraform/lambda/`, which creates the functions.
    - `terraform/s3/`, which creates an S3 bucket for static website hosting.
