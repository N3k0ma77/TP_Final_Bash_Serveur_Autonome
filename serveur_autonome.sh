#!/bin/bash

#Identification des users inactifs
#90j d'inactivite
J_INACTIF=90
CHEMIN_HOME="/home"

#Liste des users dans une liste
FICHIER_TEMP="/tmp/liste_inactifs.txt" 

#Debut analyse
echo "=== DEBUT DE L'ANALYSE ==="
echo "Recherche des repertoires inactifs depuis plus de $J_INACTIF jours..."
echo "Le resultat est  stocké dans : $FICHIER_TEMP"

#(https://www.ionos.fr/digitalguide/serveur/configuration/commande-find-sous-linux/ - https://www.christophelebot.fr/ressources/shell-bash-commandes-linux-utiles-efficaces/)
find $CHEMIN_HOME -maxdepth -type d -atime +$J_INACTIF > $FICHIER_TEMP

#Afficher la liste 
echo ""
echo "=== LISTE DES REPERTOIRES INACTIFS ==="

NB_USERS=$(wc -1 < $FICHIER_TEMP)
echo "J'ai trouve $NB_USERS repertoires inactifs :"
cat $FICHIER_TEMP
echo "---------------------------"

#Demande de confirmation avant une action
echo ""
read -p "Voulez-vous continuer le traitement sur ces repertoires ?  (oui/non) :" REPONSE
































































































#Partie de Léo
toto
