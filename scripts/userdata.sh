#!/bin/bash
set -e

# --------------------
# Instalar Docker
# --------------------
sudo apt update
sudo apt install -y ca-certificates curl gnupg

# Adicionar chave GPG do Docker
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Adicionar o repositório Docker conforme o sistema (Ubuntu ou Debian)
if grep -q "Ubuntu" /etc/os-release; then
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
elif grep -q "Debian" /etc/os-release; then
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
else
  echo "Sistema não suportado para instalação automática do Docker."
  exit 1
fi

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Adicionar o usuário ao grupo docker
# Mude para o nome de usuário adequado, por exemplo, 'admin' ou 'ubuntu'
sudo usermod -aG docker admin

# --------------------
# Instalar AWS CLI
# --------------------
sudo apt install -y unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip > /dev/null
sudo ./aws/install > /dev/null
rm -rf awscliv2.zip aws/
