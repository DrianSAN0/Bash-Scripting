#!/bin/bash
# -----------------------------------------------------------
#   Script: check_service.sh
#   Nivel 1 – Práctica de Bash Scripting
#   Estudiante: Adrian Sanchez
#   Descripción:
#       Verifica si un servicio está activo.
#       Guarda logs con timestamp.
#       Envía alerta por correo si el servicio está caído.
# -----------------------------------------------------------

# Ruta al archivo .env
ENV_PATH="$(dirname "$0")/.env"

# Carga variables del .env
if [ -f "$ENV_PATH" ]; then
    export $(grep -v '^#' "$ENV_PATH" | xargs)
else
    echo "❌ No se encontró archivo .env en $ENV_PATH"
    exit 1
fi

# Validar parámetro obligatorio
if [ -z "$1" ]; then
    echo "❌ Error: Debes especificar el nombre del servicio."
    echo "👉 Uso: $0 nombre_servicio"
    exit 1
fi

SERVICE="$1"
LOG_FILE="$(dirname "$0")/service_status.log"
EMAIL="$ALERT_EMAIL"

DATE=$(date '+%Y-%m-%d %H:%M:%S')
HOST=$(hostname)

# Verificar estado del servicio
if systemctl is-active --quiet "$SERVICE"; then
    STATUS="ACTIVE"
    MESSAGE="$DATE - $HOST - $SERVICE está ACTIVO ✔️"
else
    STATUS="INACTIVE"
    MESSAGE="$DATE - $HOST - $SERVICE está INACTIVO ❌"

    # Enviar alerta
    if [ -n "$EMAIL" ]; then
        echo "$MESSAGE" | mail -s "[$HOST] ALERTA: $SERVICE no está activo" "$EMAIL"
    fi
fi

# Guardar log
echo "$MESSAGE" >> "$LOG_FILE"

# Mostrar mensaje en consola
echo "$MESSAGE"
