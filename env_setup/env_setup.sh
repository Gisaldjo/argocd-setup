#!/bin/bash

cp .zshrc ~/.zshrc # My personal .zshrc file; Feel free to ignore or replace with your favorit .*shrc file
cp .inputrc ~/.inputrc

# Basic dependencies
sudo apt-get update
sudo apt-get install -y python3-pip build-essential procps curl file git apt-transport-https ca-certificates

# Install oh-my-zsh and plugins for it
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
sudo chsh -s $(which zsh) $USER # Set zsh as default shell

# Install brew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Docker
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo usermod -aG docker $USER

# Install Go; Newer versions broke my operator deployment process
curl -LO https://go.dev/dl/go1.21.6.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.21.6.linux-amd64.tar.gz
rm go1.21.6.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.zshrc

# Install  kubectl, kind, k9s
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl
(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /users/gp27/.zshrc
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew install kind
brew install derailed/k9s/k9s

# Force update to docker group & create kind cluster
newgrp docker << END
kind create cluster --config kind.yaml
END

# Acto requirements & relevant ArgoCD operator files
git clone https://github.com/xlab-uiuc/acto.git ../acto
cp ../acto_config ../acto/
cp ../kustomize_combined_crd.yaml ../acto/
cp ../cert-manager.yaml ../acto/
cp ../argocd-basic.yaml ../acto/
pip3 install -r ../acto/requirements.txt

# ArgoCD dependency
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.1/cert-manager.yaml
