
# Copy media files
DISTANT_FILES="/var/www/vhosts/${DB_NAME}.kanal-web.com/httpdocs/sites/default/files/"

$RSYNC -a --no-o --no-g -z -e ssh --delete --stats $SSH_USER:$DISTANT_FILES $FILES_FOLDER/sites/default/files/
sudo chmod -R 777 $FILES_FOLDER/sites/default/files/
sudo chown -R $LOCAL_USER.$LOCAL_USER $FILES_FOLDER/sites/default/files/
