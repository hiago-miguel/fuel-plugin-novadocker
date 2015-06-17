#!/bin/bash

#variable
LOG_FILE="/var/log/docker-plugin"

os_auth_url="http://`hiera management_vip`:5000/v2.0/"
os_tenant_name='admin'
os_username='admin'
os_password='admin'

#Load images from hiera
#Must do a workaround with python because
#hiera cannot return subkey correctly
images=(`hiera fuel-plugin-docker | \
sed -e 's/=>/:/g' | \
python -c \
'import json; \
import sys; \
print json.load(sys.stdin)["fuel-plugin-docker_text"].replace(" ","").replace(","," ")'`)

echo "Images to save: ${images[@]}" >> $LOG_FILE

for image in ${images[@]}
do
    echo "Trying to save $image to glance" >> $LOG_FILE
    docker pull $image && docker save $images | \
    /usr/bin/glance\
    --os-auth-url ${os_auth_url} \
    --os-tenant-name ${os_tenant_name} \
    --os-username ${os_username} \
    --os-password ${os_password} \
    image-create \
    --is-public=True \
    --container-format=docker \
    --disk-format=raw \
    --name $image
done

exit 0