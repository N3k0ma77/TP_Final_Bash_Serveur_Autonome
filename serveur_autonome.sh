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
