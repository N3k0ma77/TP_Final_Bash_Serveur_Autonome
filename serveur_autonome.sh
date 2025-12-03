#!/bin/bash
#Journalisation et robustesse (seb)

LOG_DIR="/var/log/maintenance"
LOG_FILE="$LOG_DIR/maintenance_$(date +\%Y\%m\%d_\%H\%M\%S).log"

mkdir -p "$LOG_DIR"

log_message() {
    local LEVEL="$1" 
    local MESSAGE="$2"
    
    LOG_LINE="[$(date +\%H:\%M:\%S)] [${LEVEL^^}] ${MESSAGE}"
    
    echo "$LOG_LINE" >> "$LOG_FILE"
    
    echo "$LOG_LINE"
}

