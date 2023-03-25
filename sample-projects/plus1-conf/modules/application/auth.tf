resource "aws_cognito_user_pool" "cognito_userpool" {
  name = "plus1conf-${var.env_name}-userpool"
  alias_attributes = ["email"]
  deletion_protection = var.env_name == "prod" ? "ACTIVE" : "INACTIVE"
  mfa_configuration = var.env_name == "prod" ? "ON" : "OFF"
  account_recovery_setting {
    recovery_mechanism {
      name = "verified_email"
      priority = 1
    }
    recovery_mechanism {
      name = "verified_phone_number"
      priority = 2
    }
  }
  admin_create_user_config {
    allow_admin_create_user_only = false
    invite_message_template {
      email_message = "Thank you for signing up with us. /n You user name is {username} and you can login with the temporal password {####} ."
      email_subject = "Welcome to Plus1App"
      sms_message = "Plus1App username: {username}, temporal password {####} ."
    }
  }
  password_policy {
    minimum_length = 12
    require_lowercase = true
    require_numbers = true
    require_symbols = true
    require_uppercase = true
    temporary_password_validity_days = 3
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_message = "Thank you for signing up with Plus1. /n Your verification code is {####}"
    email_subject = "Plus1 signup confirmation"
  }
  username_configuration {
    case_sensitive = false
  }
  device_configuration {
    challenge_required_on_new_device = false
    device_only_remembered_on_user_prompt = false
  }

  # email_configuration {    
  # }

  schema {
    name = "uniqueId"
    attribute_data_type = "String"
    developer_only_attribute = false
    mutable = false
    required = false
    string_attribute_constraints {
      min_length = 22
      max_length = 23
    }
  }
  schema {
    name = "userId"
    attribute_data_type = "Number"
    developer_only_attribute = false
    mutable = true
    required = false
    number_attribute_constraints  {
      min_value = 1
      max_value = 999999
    }
  }
}

resource "aws_cognito_user_pool_client" "cognito_client" {
  name = "plus1conf-${var.env_name}-userpool-client"
  user_pool_id = aws_cognito_user_pool.cognito_userpool.id
  generate_secret = false
  prevent_user_existence_errors = "ENABLED"
  access_token_validity = 30
  id_token_validity = 30
  refresh_token_validity = 1
  token_validity_units {
    access_token = "minutes"
    id_token = "minutes"
    refresh_token = "days"
  }
  explicit_auth_flows = [
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}
