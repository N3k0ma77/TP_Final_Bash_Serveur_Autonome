#!/bin/bash

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
toto
