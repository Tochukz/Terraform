resource "aws_dynamodb_table" "foodstore_dynamo" {
  name         = "foodstore_db"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "foodId"
  attribute {
    name = "foodId"
    type = "S"
  }
}

resource "aws_dynamodb_table" "petstore_dynamo" {
  name         = "petstore_db"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "petId"
  attribute {
    name = "petId"
    type = "S"
  }
}
