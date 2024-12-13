#!/bin/bash

# Limpa a tela
clear

# URL base do repositório
REPO_URL="https://raw.githubusercontent.com/lipey1/ubuntu-vps-egg/main"

# Download dos arquivos necessários
curl -Lo /entrypoint.sh "${REPO_URL}/entrypoint.sh"
curl -Lo /run.sh "${REPO_URL}/run.sh"
curl -Lo /helper.sh "${REPO_URL}/helper.sh"

# Torna os scripts executáveis
chmod +x /entrypoint.sh /run.sh /helper.sh

echo "🐧 Instalação do Ubuntu VPS"
echo "==========================="
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
    1) UBUNTU_VERSION="24.04" ;;
    2) UBUNTU_VERSION="23.10" ;;
    3) UBUNTU_VERSION="22.04" ;;
    4) UBUNTU_VERSION="20.04" ;;
    5) UBUNTU_VERSION="18.04" ;;
    6) UBUNTU_VERSION="16.04" ;;
    *) 
        echo "❌ Opção inválida!"
        exit 1
        ;;
esac

echo
echo "🔄 Iniciando instalação do Ubuntu ${UBUNTU_VERSION}..."

# Instala pacotes básicos
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

echo "✅ Instalação do Ubuntu ${UBUNTU_VERSION} concluída com sucesso!"
echo
echo "📝 Informações da versão instalada:"
case ${UBUNTU_VERSION} in
    "24.04") echo "Ubuntu Noble Numbat - Versão em desenvolvimento (Abril 2024)" ;;
    "23.10") echo "Ubuntu Mantic Minotaur - Versão atual (Outubro 2023)" ;;
    "22.04") echo "Ubuntu Jammy Jellyfish - Versão LTS (Suporte até 2027)" ;;
    "20.04") echo "Ubuntu Focal Fossa - Versão LTS (Suporte até 2025)" ;;
    "18.04") echo "Ubuntu Bionic Beaver - Versão LTS (Suporte até 2028)" ;;
    "16.04") echo "Ubuntu Xenial Xerus - Versão LTS (Suporte até 2026)" ;;
esac
echo
echo "🚀 Sistema pronto para uso!"