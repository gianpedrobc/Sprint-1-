# Projeto: Infraestrutura Web com Monitoramento na AWS

## Objetivo:

Criar uma estrutura básica para um site que funcione 24 horas por dia, de forma segura, na AWS.  
O projeto utiliza uma VPC com 4 sub-redes (2 públicas e 2 privadas), uma instância EC2 rodando um servidor NGINX que serve uma aplicação React, além de um sistema de monitoramento com alerta automático via Discord em caso de falha.

---

## 🌐 Diagrama da Arquitetura:
<div>
<img src="https://github.com/gianpedrobc/Sprint-1-/issues/1#issue-3274602895 width="700px" />
</div>
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

# Atualiza pacotes
apt update -y && apt upgrade -y

# Instala nginx, git, node e npm
apt install -y nginx git curl
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# Clona o repositório com o projeto React
cd /opt
git clone https:https://github.com/Portifolio.git
cd Portifolio 

# Instala dependências e cria build
npm install
npm run build

# Copia a build para o diretório do NGINX
rm -rf /var/www/html/*
cp -r build/* /var/www/html/

# Inicia e habilita o NGINX
systemctl start nginx
systemctl enable nginx

```

---

## 📡 Script de Monitoramento

```bash
#!/bin/bash
# pega o ipv4 publico da ec2 
URL=$(curl -s https://checkip.amazonaws.com)

LOG="/var/log/monitor.log"

# Pega o código de resposta do site (200 = OK)
STATUS=$(curl -s -o /dev/null -w "%{http_code}" $URL )

DATA=$(date "+%Y-%m-%d %H:%M:%S")

if [ "$STATUS" -ne 200 ]; then

        echo "$DATA - ERRO: Aplicação fora do ar (status $STATUS)" >> $LOG

  # Envia alerta para o Discord
  curl -H "Content-Type: application/json" \
       -X POST \
       -d "{\"content\": \"🚨 ALERTA: Site fora do ar! Código $STATUS\"}" \
       https://discord.com

#else
#comentado para nao encher o log 
        #echo "$DATA - OK: Aplicação funcionando (status $STATUS)" >> $LOG
fi
```

### 🔎Agendamento no cron:
```
* * * * * /home/ubuntu/monitoramento.sh
```
Isso garante que o script rode a cada minuto.

---

### 🧪 Testes Realizados
obs: O horario esta diferente por causa da localizacao do servidor e a minha 
 ## ✅ Logs do Servidor Nginx 
![Teste Monitoramento - Imagem 2](https://github.com/gianpedrobc/Sprint-1-/raw/e2c1ce3ad46d2de603cccc7161c2498fe62abc91/Documentos/img-test-2.png)

 ## ❌ Servidor para com webhook funcionando 
![Teste Monitoramento - Imagem](https://github.com/gianpedrobc/Sprint-1-/raw/main/Documentos/img-test.png)

### 💡 Trecho do CloudFormation
```
AWSTemplateFormatVersion: '2010-09-09'
Description: Criar EC2 com Nginx, script de inicialização e tags

Resources:
  EC2Instance:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: t2.micro
      ImageId: ami-020cba7c55df1f615
      KeyName: Server-nginx
      SubnetId: "*****"
      SecurityGroupIds:
        	-"*****"
```


