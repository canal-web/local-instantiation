
OLD_HOSTS=`mysql --silent --skip-column-names -u$LOCAL_DB_USER -p$LOCAL_DB_PASSWORD $LOCAL_DB_NAME -e 'select GROUP_CONCAT(config_id SEPARATOR ",") from core_config_data where value like "%http%" and path like "%web/%" and path like "%secure%" GROUP BY "all"'`

mysql -u$LOCAL_DB_USER -p$LOCAL_DB_PASSWORD $LOCAL_DB_NAME -e "UPDATE core_config_data SET value='http://$LOCAL_HOST/' WHERE config_id IN ($OLD_HOSTS)"


for DIR in session locks cache
do
    rm -rf "$SITE_BASE/var/$DIR"
done

# Copy media files
DISTANT_FILES="/var/www/vhosts/${DB_NAME}.kanal-web.com/httpdocs/media"

$RSYNC -a --no-o --no-g -z -e ssh --delete --stats $SSH_USER:$DISTANT_FILES $FILES_FOLDER
sudo chmod -R 777 $FILES_FOLDER/media
sudo chown -R $CURRENT_USER.$CURRENT_USER $FILES_FOLDER/media
