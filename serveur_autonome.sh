#!/bin/bash
#Journalisation et robustesse (seb)

#1. Fonction de journalisation standardisée

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

#2. Gestion des interruptions utilisateur


interruption_handler() {
    
    log_message "ERROR" "Script interrompu par l'utilisateur"
    

    exit 1
}

trap interruption_handler INT

