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

# Cria script de monitoramento
cat << 'EOF' > /usr/local/bin/monitor.sh
#!/bin/bash

URL=$(curl -s https://checkip.amazonaws.com)
LOG="/var/log/monitor.log"
STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$URL)
DATA=$(date "+%Y-%m-%d %H:%M:%S")

if [ "$STATUS" -ne 200 ]; then
    echo "$DATA - ERRO: Aplicação fora do ar (status $STATUS)" >> $LOG

    curl -H "Content-Type: application/json" \
         -X POST \
         -d "{\"content\": \"🚨 ALERTA: Site fora do ar! Código $STATUS\"}" \
         https://discord.com
fi
EOF

# Dá permissão de execução
chmod +x /usr/local/bin/monitor.sh

# Cria o log
touch /var/log/monitor.log

# Agenda no cron para rodar a cada minuto
(crontab -l 2>/dev/null; echo "* * * * * /usr/local/bin/monitor.sh") | crontab -

# Reinicia o NGINX por segurança
systemctl restart nginx
