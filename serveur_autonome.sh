#!/bin/bash

# Script simple de vérification système
# Nathan

echo "=== Vérification du système ==="
echo ""

# Définir les seuils
SEUIL_DISQUE=75
SEUIL_RAM=90

# Vérifier l'espace disque trouvé sur https://labex.io/
echo "Espace disque sur / :"
df -h /

echo ""

# Extraire juste le pourcentage (sans le %)
DISQUE=$(df / | grep / | awk '{print $5}' | tr -d '%')
echo "Utilisation du disque : $DISQUE%"

# Vérifier le seuil disque
if [ $DISQUE -ge $SEUIL_DISQUE ]; then
    echo "WARNING : Seuil disque dépassé ($DISQUE% >= $SEUIL_DISQUE%)"
else
    echo "OK : Espace disque suffisant"
fi

echo ""

# Vérifier la mémoire RAM
echo "Mémoire RAM :"
free -h

echo ""

# Calculer le pourcentage de RAM utilisée trouvé sur https://unix.stackexchange.com/
TOTAL_RAM=$(free | grep Mem | awk '{print $2}')
USED_RAM=$(free | grep Mem | awk '{print $3}')
POURCENTAGE_RAM=$((USED_RAM * 100 / TOTAL_RAM))

echo "RAM utilisée : $POURCENTAGE_RAM%"

# Vérifier le seuil RAM
if [ $POURCENTAGE_RAM -ge $SEUIL_RAM ]; then
    echo "WARNING : Seuil RAM dépassé ($POURCENTAGE_RAM% >= $SEUIL_RAM%)"
else
    echo "OK : Mémoire RAM suffisante"
fi

#!/bin/bash

# ==============================================================================
# Script : Sauvegarde Dynamique et Integrite
# Description : Archive un repertoire, le compresse et verifie son integrite.
# Usage : ./backup.sh <source_dir> <dest_dir>
# Auteur : Theo L. - R4 Administration des systemes 2025-2026
# ==============================================================================

echo "=============================================="
echo "===   SAUVEGARDE DYNAMIQUE ET INTEGRITE     ==="
echo "=============================================="
echo ""

# ==============================================================================
# Fonction : suppression des accents
# ==============================================================================
enlever_accents() {
    echo "$1" | iconv -f UTF-8 -t ASCII//TRANSLIT
}

# ==============================================================================
# 1. GESTION DES ARGUMENTS ET VALIDATION DE LA CIBLE
# ==============================================================================

echo "=== 1. Gestion des arguments et validation de la cible ==="
echo ""

if [ "$#" -ne 2 ]; then
    echo "Erreur : Le script necessite exactement 2 arguments."
    echo "Usage : $0 <chemin_absolu_source> <chemin_destination>"
    echo ""
    exit 102
fi

SOURCE_DIR="$1"
DEST_BASE="$2"

echo "Arguments recus :"
echo "  - Repertoire source      : $SOURCE_DIR"
echo "  - Repertoire destination : $DEST_BASE"
echo ""

if [ -z "$SOURCE_DIR" ]; then
    echo "Erreur : L'argument source est vide."
    exit 102
fi

if [ ! -e "$SOURCE_DIR" ]; then
    echo "Erreur : Le chemin '$SOURCE_DIR' n'existe pas."
    exit 102
fi

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Erreur : '$SOURCE_DIR' n'est pas un repertoire."
    exit 102
fi

# ==============================================================================
# 2. ARCHIVAGE ET COMPRESSION
# ==============================================================================

echo "=== 2. Archivage et compression ==="
echo ""

mkdir -p "$DEST_BASE"

NOM_REP_ORIG=$(basename "$SOURCE_DIR")
NOM_REP=$(enlever_accents "$NOM_REP_ORIG")

DATE_STR=$(date +%Y_%m_%d_%Hh%M)
NOM_ARCHIVE="${NOM_REP}_${DATE_STR}.tar.gz"
FULL_DEST_PATH="$DEST_BASE/$NOM_ARCHIVE"

echo "Informations de l'archive :"
echo "  - Nom du repertoire source : $NOM_REP_ORIG"
echo "  - Nom nettoye              : $NOM_REP"
echo "  - Nom de l'archive          : $NOM_ARCHIVE"
echo "  - Chemin complet            : $FULL_DEST_PATH"
echo ""

echo "Archivage en cours..."
tar -czf "$FULL_DEST_PATH" -C "$(dirname "$SOURCE_DIR")" "$NOM_REP_ORIG"

if [ $? -ne 0 ]; then
    echo "Erreur lors de l'archivage."
    exit 1
fi

# ==============================================================================
# 3. VERIFICATION D'INTEGRITE
# ==============================================================================

echo ""
echo "=== 3. Verification de l'integrite ==="
echo ""

CHECKSUM_FILE="${FULL_DEST_PATH}.sha256"

sha256sum "$FULL_DEST_PATH" > "$CHECKSUM_FILE"

if [ $? -ne 0 ]; then
    echo "Erreur lors de la generation du checksum."
    exit 1
fi

echo "Checksum SHA256 genere :"
cat "$CHECKSUM_FILE"
echo ""

echo "Sauvegarde terminee avec succes."
exit 0

# ==============================================================================
# RÉSUMÉ FINAL
# ==============================================================================

echo "=============================================="
echo "===          RÉSUMÉ DE LA SAUVEGARDE      ==="
echo "=============================================="
echo ""
echo "✓ Sauvegarde terminée avec succès"
echo ""
echo "Emplacement de l'archive :"
echo "  $FULL_DEST_PATH"
echo ""
echo "Checksum SHA256 :"
echo "  $(cat ${FULL_DEST_PATH}.sha256 | awk '{print $1}')"
echo ""
echo "Nombre de fichiers archivés : $(tar -tzf "$FULL_DEST_PATH" | wc -l)"
echo ""
echo "=============================================="

#Identification des users inactifs
#90j d'inactivite
J_INACTIF=90
CHEMIN_HOME="/home"

#Liste des users dans une liste
FICHIER_TEMP="/tmp/liste_inactifs.txt" 

#Vidage du dossier s'il existe deja
> $FICHIER_TEMP

#Debut analyse
echo "=== DEBUT DE L'ANALYSE ==="
echo "Recherche des repertoires inactifs depuis plus de" $J_INACTIF "jours..."
echo "Le resultat est  stocké dans :" $FICHIER_TEMP

#(https://www.ionos.fr/digitalguide/serveur/configuration/commande-find-sous-linux/ - https://www.christophelebot.fr/ressources/shell-bash-commandes-linux-utiles-efficaces/)
find $CHEMIN_HOME -maxdepth -type d -atime +$J_INACTIF > $FICHIER_TEMP

#Afficher la liste
echo ""
echo "=== LISTE DES REPERTOIRES INACTIFS ==="

$NB_USERS=$(wc -1 < $FICHIER_TEMP)
echo "J'ai trouve" $NB_USERS "repertoires inactifs :"
cat $FICHIER_TEMP
echo "---------------------------"

#Demande de confirmation avant l'action
echo ""
read -p "Voulez-vous continuer le traitement sur ces repertoires ?  (oui/non) :" REPONSE

#Verification simple 
if [$REPONSE == "o"] [$REPONSE == "O"]; then
echo "OK, vous avez confirme. Les prochaines actions peuvent etre lancées ici"
#Si d'autres actions devait être faites, elles iront ici
else 
echo "Action annulée. Rien n'est modifié.
fi

#Suppression du fichier temp
rm $FICHIER_TEMP
echo "Nettoyage terminé."
echo "=== Fin de lanalyse ==="
exit 0

#Partie de Léo
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

#3. Planification

#Commande pour l'execution automatique : 30 23 * * * /opt/scripts/serveur_autonome.sh /etc
