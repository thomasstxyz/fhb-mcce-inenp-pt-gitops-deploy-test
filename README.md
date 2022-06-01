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

The source of the Angular App, which gets deployed to the S3 bucket,
is hosted in another Git repository 
[https://github.com/thomasstxyz/FHB-MCCE-2022-Todo-Frontend-2](https://github.com/thomasstxyz/FHB-MCCE-2022-Todo-Frontend-2)
