#!bin/bash

## settings file
cat 'templates/drupal/settings.php' | sed -e "s/TOKENSITENAME/${DB_NAME}/g" -e "s,LOCAL_HOST,${LOCAL_HOST},g" -e "s,LOCAL_USER_DB,${LOCAL_USER_DB},g" -e "s,LOCAL_PASSWD_DB,${LOCAL_PASSWD_DB},g" >${LOCAL_DIR}web/sites/default/settings.php
