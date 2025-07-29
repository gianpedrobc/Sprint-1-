# Projeto: Infraestrutura Web com Monitoramento na AWS

## Objetivo:

Criar uma estrutura básica para um site que funcione 24 horas por dia, de forma segura, na AWS.  
O projeto utiliza uma VPC com 4 sub-redes (2 públicas e 2 privadas), uma instância EC2 rodando um servidor NGINX que serve uma aplicação React, além de um sistema de monitoramento com alerta automático via Discord em caso de falha.

---

## 🌐 Diagrama da Arquitetura:
[`documentos/infra.img`]

---

## ⚙️ Recursos Utilizados

- Amazon VPC (4 subnets)
- Internet Gateway e NAT Gateway
- EC2 (t2.micro - Ubuntu 22.04)
- Security Groups
- NGINX, Git, Node.js
- Webhook do Discord
- Script de monitoramento (bash)
- CloudFormation (YAML)

---

## 🔧 Instalação via User Data

```bash
#!/bin/bash
apt update -y && apt upgrade -y
apt install -y nginx git curl
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

cd /opt
git clone https://github.com/SEU_USUARIO/SEU_REPOSITORIO.git site
cd site
npm install
npm run build

rm -rf /var/www/html/*
cp -r build/* /var/www/html/

systemctl start nginx
systemctl enable nginx
```

---

## 📡 Script de Monitoramento

```bash
#!/bin/bash
URL=$(curl -s https://checkip.amazonaws.com)
STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$URL)
DATA=$(date "+%Y-%m-%d %H:%M:%S")
LOG="/var/log/monitor.log"

if [ "$STATUS" -ne 200 ]; then
  echo "$DATA - ERRO: Site fora do ar (status $STATUS)" >> $LOG
  curl -H "Content-Type: application/json"        -X POST        -d "{"content": "🚨 ALERTA: Site fora do ar! Código $STATUS"}"        https://discord.com/api/webhooks/SEU_WEBHOOK
fi
```

Agendado via `cron` para rodar a cada minuto.

---

## 🧠 Conclusão

Projeto DevOps com AWS demonstrando automação e monitoramento.

Feito com ☁️ por [Seu Nome].