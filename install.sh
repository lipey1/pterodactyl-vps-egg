#!/bin/bash

# Limpa a tela
clear

echo "🐧 Instalação do Sistema Linux"
echo "============================="
echo
echo "Versões disponíveis:"
echo "1) Ubuntu 24.04 (Noble Numbat) - Desenvolvimento"
echo "2) Ubuntu 23.10 (Mantic Minotaur) - Atual"
echo "3) Ubuntu 22.04 (Jammy Jellyfish) - LTS"
echo "4) Ubuntu 20.04 (Focal Fossa) - LTS"
echo "5) Ubuntu 18.04 (Bionic Beaver) - LTS"
echo "6) Ubuntu 16.04 (Xenial Xerus) - LTS"
echo
echo "Digite o número da versão desejada (1-6):"
read choice

case $choice in
    1) VERSION="noble" ;;
    2) VERSION="mantic" ;;
    3) VERSION="jammy" ;;
    4) VERSION="focal" ;;
    5) VERSION="bionic" ;;
    6) VERSION="xenial" ;;
    *) 
        echo "❌ Opção inválida!"
        exit 1
        ;;
esac

echo
echo "🔄 Iniciando instalação do Ubuntu ${VERSION}..."

# Cria diretório do sistema
mkdir -p /home/container
cd /home/container

# Instala o sistema base usando debootstrap
debootstrap --arch=amd64 ${VERSION} . http://archive.ubuntu.com/ubuntu/

# Configura o sistema básico
chroot . /bin/bash -c "
    # Configura hostname
    echo 'vps' > /etc/hostname

    # Configura sources.list
    cat > /etc/apt/sources.list <<EOF
deb http://archive.ubuntu.com/ubuntu ${VERSION} main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu ${VERSION}-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu ${VERSION}-security main restricted universe multiverse
EOF

    # Atualiza e instala pacotes básicos
    apt-get update
    apt-get install -y \
        curl \
        wget \
        sudo \
        bash \
        openssh-server \
        ca-certificates \
        locales \
        nano \
        htop \
        net-tools

    # Configura locale
    locale-gen en_US.UTF-8
    update-locale LANG=en_US.UTF-8

    # Configura senha root
    echo 'root:vps' | chpasswd
"

# Download dos scripts necessários
curl -Lo /entrypoint.sh "https://raw.githubusercontent.com/lipey1/ubuntu-vps-egg/main/entrypoint.sh"
curl -Lo /run.sh "https://raw.githubusercontent.com/lipey1/ubuntu-vps-egg/main/run.sh"
curl -Lo /helper.sh "https://raw.githubusercontent.com/lipey1/ubuntu-vps-egg/main/helper.sh"

# Torna os scripts executáveis
chmod +x /entrypoint.sh /run.sh /helper.sh

echo "✅ Instalação concluída com sucesso!"
echo
echo "📝 Informações do sistema instalado:"
case ${VERSION} in
    "noble") echo "Ubuntu 24.04 Noble Numbat - Versão em desenvolvimento (Abril 2024)" ;;
    "mantic") echo "Ubuntu 23.10 Mantic Minotaur - Versão atual (Outubro 2023)" ;;
    "jammy") echo "Ubuntu 22.04 Jammy Jellyfish - Versão LTS (Suporte até 2027)" ;;
    "focal") echo "Ubuntu 20.04 Focal Fossa - Versão LTS (Suporte até 2025)" ;;
    "bionic") echo "Ubuntu 18.04 Bionic Beaver - Versão LTS (Suporte até 2028)" ;;
    "xenial") echo "Ubuntu 16.04 Xenial Xerus - Versão LTS (Suporte até 2026)" ;;
esac
echo
echo "🚀 Sistema pronto para uso!"