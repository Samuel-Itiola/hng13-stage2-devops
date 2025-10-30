#!/bin/bash
# Run this script on EC2 instance

# Update system
sudo yum update -y

# Install Docker
sudo yum install -y docker git
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

# Install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Clone repository
git clone https://github.com/your-username/hng13-stage2-devops.git
cd hng13-stage2-devops

# Deploy with production config
docker-compose -f docker-compose.prod.yml up -d

echo "Deployment complete!"
echo "Access your application at:"
echo "Main service: http://$(curl -s ifconfig.me):8080/version"
echo "Blue direct: http://$(curl -s ifconfig.me):8081/version"
echo "Green direct: http://$(curl -s ifconfig.me):8082/version"