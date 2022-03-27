# Bastion Host
resource "aws_security_group" "jenkins_bastion_sg" {
  name        = "jenkins-bastion-sg"
  description = "Bastion Security Group"
  vpc_id      = aws_vpc.jenkins_vpc.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.my_ip]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-bastion-sg"
  }
}

resource "aws_instance" "jenkins_bastion_ec2" {
  ami           = data.aws_ami.bastion.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.jenkins_bastion_subnet.id
  vpc_security_group_ids = [aws_security_group.jenkins_bastion_sg.id]
  key_name        = aws_key_pair.deployer.key_name
  availability_zone = "eu-central-1b"

  tags = {
    Name = "jenkins-bastion-ec2"
  }
}

# Jenkins Master Host
resource "aws_security_group" "jenkins_master_sg" {
  name        = "jenkins_master-sg"
  description = "Jenkins Master Security Group"
  vpc_id      = aws_vpc.jenkins_vpc.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [ "${aws_instance.jenkins_bastion_ec2.private_ip}/32" ]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-master-sg"
  }
}


resource "aws_instance" "jenkins_master_ec2" {
  ami           = data.aws_ami.jenkins_master.id
  instance_type = "t2.micro"
	subnet_id = aws_subnet.jenkins_master_subnet.id
	vpc_security_group_ids = [aws_security_group.jenkins_master_sg.id]
	key_name        = aws_key_pair.deployer.key_name
  availability_zone = "eu-central-1b"
  user_data_replace_on_change = true

  user_data = <<EOF
#!/bin/bash
sudo /etc/init.d/jenkins stop
sudo sed -i 's=<host>.*</host>=<host>${aws_instance.jenkins_node_ec2.private_ip}</host>=g' /var/lib/jenkins/nodes/remote-node/config.xml
sudo /etc/init.d/jenkins start
EOF

  tags = {
    Name = "jenkins-master-ec2"
  }
}