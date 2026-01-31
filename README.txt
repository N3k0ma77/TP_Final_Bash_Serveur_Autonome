Serveur Autonome – Script Bash


Fonctionnalités
---------------
- Vérification de l’espace disque, de la RAM et des processus gourmands
- Contrôle des services critiques
- Sauvegarde compressée du répertoire source + checksum SHA256
- Détection des utilisateurs inactifs
- Journalisation complète dans /var/log/maintenance
- Gestion des erreurs et interruption

Utilisation
-----------
1. Rendre le script exécutable :
   chmod +x serveur_autonome.sh

2. Exécuter le script :
   sudo ./serveur_autonome.sh /repertoire/source /repertoire/destination

Exemple :
   sudo ./serveur_autonome.sh /etc /mnt/sauvegardes

Planification Cron
------------------
Exécution quotidienne à 23h30 :
30 23 * * * root /opt/scripts/serveur_autonome.sh /etc /mnt/sauvegardes