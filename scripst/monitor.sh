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