#!/bin/bash

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
