#!/bin/bash

REPO_URL="https://github.com/rayner-villalba-coderoad-com/clash-of-clan"
APP_DIR="$HOME/clash-of-clan"
DEPLOY_LOG="$HOME/deploy.log"
WEB_DIR="/var/www/html"
WEBHOOK_URL="https://discord.com/api/webhooks/1438144097515737263/ng0nWQa8NW0hebKBvzFJNGb-0xMSkfWNSxWyESFH7jLIdaP_OUFSmJv7IvgKykRLbmFd"

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

log() {
    echo "$TIMESTAMP - $1" | tee -a "$DEPLOY_LOG"
}

if [ ! -d "$APP_DIR/.git" ]; then
    log "Repositorio no encontrado. Clonando..."
    git clone "$REPO_URL" "$APP_DIR"
    if [ $? -ne 0 ]; then
        log "ERROR: git clone falló. Abortando."
        exit 1
    fi
else
    log "Repositorio encontrado. Actualizando..."
    cd "$APP_DIR" || { log "ERROR: No se puede acceder a $APP_DIR"; exit 1; }
    git pull origin main
    if [ $? -ne 0 ]; then
        log "ERROR: git pull falló. Abortando."
        exit 1
    fi
fi

log "Copiando archivos a $WEB_DIR..."
sudo cp -r "$APP_DIR/"* "$WEB_DIR/"
if [ $? -ne 0 ]; then
    log "ERROR: Falló copiar archivos a $WEB_DIR"
    exit 1
fi

log "Reiniciando Apache..."
sudo systemctl restart apache2
if [ $? -ne 0 ]; then
    log "ERROR: Falló reiniciar Apache"
    exit 1
fi

if [ -n "$WEBHOOK_URL" ]; then
    MESSAGE="Despliegue exitoso de clash-of-clan en $TIMESTAMP"
    curl -s -X POST "$WEBHOOK_URL" \
         -H "Content-Type: application/json" \
         -d "{\"content\": \"$MESSAGE\"}"
    log "Notificación enviada al webhook."
fi

log "Despliegue completado"
