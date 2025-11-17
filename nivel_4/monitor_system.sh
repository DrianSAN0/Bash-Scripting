#!/bin/bash

CPU_LIMIT=80
RAM_LIMIT=80
DISK_LIMIT=80
ALERT_LOG="alerts.log"
DATE=$(date +%Y%m%d)
METRICS_LOG="metrics_$DATE.log"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

log_alert() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') ALERTA: $message" | tee -a "$ALERT_LOG"
}

check_cpu() {
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100-$8}')
    CPU_USAGE_INT=${CPU_USAGE%.*}
    if [ "$CPU_USAGE_INT" -ge "$CPU_LIMIT" ]; then
        echo -e "${RED}CPU: $CPU_USAGE% (ALERTA)${NC}"
        log_alert "CPU alta: $CPU_USAGE%"
    else
        echo -e "${GREEN}CPU: $CPU_USAGE% (OK)${NC}"
    fi
    echo "$(date '+%H:%M:%S') CPU:$CPU_USAGE%" >> "$METRICS_LOG"
}

check_ram() {
    RAM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
    RAM_USED=$(free -m | awk '/Mem:/ {print $3}')
    RAM_USAGE=$((RAM_USED * 100 / RAM_TOTAL))
    if [ "$RAM_USAGE" -ge "$RAM_LIMIT" ]; then
        echo -e "${RED}RAM: $RAM_USAGE% (ALERTA)${NC}"
        log_alert "RAM alta: $RAM_USAGE%"
    else
        echo -e "${GREEN}RAM: $RAM_USAGE% (OK)${NC}"
    fi
    echo "$(date '+%H:%M:%S') RAM:$RAM_USAGE%" >> "$METRICS_LOG"
}

check_disk() {
    DISK_USAGE=$(df / | awk 'NR==2 {gsub("%",""); print $5}')
    if [ "$DISK_USAGE" -ge "$DISK_LIMIT" ]; then
        echo -e "${RED}DISCO: $DISK_USAGE% (ALERTA)${NC}"
        log_alert "Disco lleno: $DISK_USAGE%"
    else
        echo -e "${GREEN}DISCO: $DISK_USAGE% (OK)${NC}"
    fi
    echo "$(date '+%H:%M:%S') DISCO:$DISK_USAGE%" >> "$METRICS_LOG"
}

echo "------ Monitoreo del sistema $(date '+%Y-%m-%d %H:%M:%S') ------" >> "$METRICS_LOG"

check_cpu
check_ram
check_disk
