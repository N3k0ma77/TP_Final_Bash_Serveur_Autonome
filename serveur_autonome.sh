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

# ==============================================================================
# Script : Sauvegarde Dynamique et Intégrité
# Description : Archive un répertoire, le compresse et vérifie son intégrité.
# Usage : ./backup.sh <source_dir> <dest_dir>
# Auteur : Théo L. - R4 Administration des systèmes 2025-2026
# ==============================================================================

echo "=============================================="
echo "===   SAUVEGARDE DYNAMIQUE ET INTÉGRITÉ   ==="
echo "=============================================="
echo ""

# ==============================================================================
# 1. GESTION DES ARGUMENTS ET VALIDATION DU CIBLE
# ==============================================================================

echo "=== 1. Gestion des arguments et validation du cible ==="
echo ""

# Vérification du nombre d'arguments
if [ "$#" -ne 2 ]; then
    echo "Erreur : Le script nécessite exactement 2 arguments."
    echo "Usage: $0 <chemin_absolu_source> <chemin_destination>"
    echo ""
    echo "Exemple:"
    echo "  $0 /etc /mnt/backup"
    exit 102
fi

SOURCE_DIR="$1"
DEST_BASE="$2"

echo "Arguments reçus :"
echo "  - Répertoire source      : $SOURCE_DIR"
echo "  - Répertoire destination : $DEST_BASE"
echo ""

# Vérification : l'argument est-il présent ?
if [ -z "$SOURCE_DIR" ]; then
    echo "Erreur : L'argument source est vide."
    exit 102
fi

# Vérification : l'argument existe-t-il ?
if [ ! -e "$SOURCE_DIR" ]; then
    echo "Erreur : Le chemin '$SOURCE_DIR' n'existe pas."
    exit 102
fi

# Vérification : est-ce un répertoire ?
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Erreur : '$SOURCE_DIR' n'est pas un répertoire."
    exit 102
fi

echo "✓ Validation réussie : '$SOURCE_DIR' est un répertoire valide."
echo ""

# ==============================================================================
# 2. ARCHIVAGE ET COMPRESSION AVANCÉE
# ==============================================================================

echo "=== 2. Archivage et compression avancée ==="
echo ""

# Créer le répertoire de destination /mnt/sauvegardes s'il n'existe pas
mkdir -p "$DEST_BASE"
echo "✓ Répertoire de destination créé/vérifié : $DEST_BASE"
echo ""

# Nom dynamique de l'archive : NOM_REP_ANNEE_MOIS_JOUR_HEURE
NOM_REP=$(basename "$SOURCE_DIR")
DATE_STR=$(date +%Y_%m_%d_%Hh%M)
NOM_ARCHIVE="${NOM_REP}_${DATE_STR}.tar.gz"

FULL_DEST_PATH="$DEST_BASE/$NOM_ARCHIVE"

echo "Informations de l'archive :"
echo "  - Nom du répertoire : $NOM_REP"
echo "  - Date/Heure        : $DATE_STR"
echo "  - Nom de l'archive  : $NOM_ARCHIVE"
echo "  - Chemin complet    : $FULL_DEST_PATH"
echo ""

# Archiver le répertoire cible en utilisant la compression Gzip
echo "Archivage en cours avec compression Gzip..."
tar -czf "$FULL_DEST_PATH" -C "$(dirname "$SOURCE_DIR")" "$NOM_REP"

if [ $? -eq 0 ]; then
    echo "✓ Archivage réussi : $NOM_ARCHIVE"
    echo "  Taille : $(du -h "$FULL_DEST_PATH" | cut -f1)"
else
    echo "✗ Erreur lors de l'archivage."
    exit 1
fi
echo ""

# ==============================================================================
# 3. VÉRIFICATION D'INTÉGRITÉ
# ==============================================================================

echo "=== 3. Vérification d'intégrité ==="
echo ""

# Générer le checksum en SHA256
echo "Génération du checksum SHA256..."
sha256sum "$FULL_DEST_PATH" > "${FULL_DEST_PATH}.sha256"

if [ $? -eq 0 ]; then
    echo "✓ Checksum SHA256 généré avec succès"
    echo "  Fichier : ${FULL_DEST_PATH}.sha256"
else
    echo "✗ Erreur lors de la génération du checksum"
    exit 1
fi
echo ""

# Stocker le checksum dans un fichier séparé portant le même nom que l'archive
echo "Contenu du fichier checksum :"
cat "${FULL_DEST_PATH}.sha256"
echo ""

# Vérification ultérieure : tester l'intégrité de l'archive
echo "Vérification de l'intégrité de l'archive..."
tar -tzf "$FULL_DEST_PATH" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "✓ Vérification réussie : L'archive est intègre."
else
    echo "✗ Alerte : L'archive semble corrompue."
    exit 1
fi
echo ""

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
