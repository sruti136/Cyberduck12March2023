locals {
  name = "cyber-mysql"
  bucket_name = "terraform-state-cyber-110323"
  region      = "eu-west-2"

    user_data = <<-EOT
    #!/bin/bash
    echo "Hello CyberDuck!"
  EOT
}
