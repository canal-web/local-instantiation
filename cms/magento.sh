#!bin/bash

# Create var folder
if [[ ! -d ${LOCAL_DIR}web/var ]]; then
    mkdir ${LOCAL_DIR}web/var
    sudo chown -R ${LOCAL_USER}.${LOCAL_GROUP} ${LOCAL_DIR}web/var
    sudo chmod -R 777 ${LOCAL_DIR}web/var
fi

## local xml
cat 'templates/magento/local.xml.base' | sed -e "s/TOKENSITENAME/${SITE_NAME}/g" -e "s,LOCAL_HOST,${LOCAL_HOST},g" -e "s,LOCAL_USER_DB,${LOCAL_USER_DB},g" -e "s,LOCAL_PASSWD_DB,${LOCAL_PASSWD_DB},g" >${LOCAL_DIR}web/app/etc/local.xml
