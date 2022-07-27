terraform {
  backend "s3" {
    profile = "default"
    region  = "us-east-1"
    bucket  = "asselstar"
    key     = "project_state_file"
  } 
}
  

