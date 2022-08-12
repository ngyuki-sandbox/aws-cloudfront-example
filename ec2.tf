
data "aws_ssm_parameter" "ami_amazon_linux" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

locals {
  ec2_user_data = <<-EOS
    #cloud-config
    timezone: "Asia/Tokyo"
    hostname: "${var.prefix}-server"
    ssh_authorized_keys: ${jsonencode(var.authorized_keys)}
    runcmd:
      - yum install -y httpd php
      - systemctl enable httpd --now
    write_files:
      - path: /var/www/html/index.php
        content: |
          <?php phpinfo();
  EOS
}

# output "ec2_user_data" {
#   value = local.ec2_user_data
# }

resource "aws_instance" "server" {
  # ami = "ami-0afe0424c9fd49524" # OL8.5
  ami                         = data.aws_ssm_parameter.ami_amazon_linux.value
  instance_type               = "t3.nano"
  subnet_id                   = data.aws_subnets.main.ids[0]
  vpc_security_group_ids      = [aws_security_group.main.id]
  iam_instance_profile        = aws_iam_instance_profile.server.name
  ebs_optimized               = false
  monitoring                  = false
  associate_public_ip_address = true

  user_data = local.ec2_user_data

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  tags = {
    Name = "${var.prefix}-server"
  }
}

output "server" {
  value = {
    instance_id = aws_instance.server.id
  }
}

################################################################################
# ELB

resource "aws_lb_target_group_attachment" "server" {
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = aws_instance.server.id
}

################################################################################
# IAM

resource "aws_iam_role" "server" {
  name = "${var.prefix}-server"

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Effect : "Allow",
        Principal : {
          Service : "ec2.amazonaws.com",
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "server" {
  name = "${var.prefix}-server"
  role = aws_iam_role.server.name
}

resource "aws_iam_role_policy_attachment" "server" {
  for_each = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  }
  role       = aws_iam_role.server.name
  policy_arn = each.value
}
