#!/bin/bash
#set -x

# This script checks if there is a file containing the GNOS name of the download in progress and changes Sensu client's name in order to allow bandwitdh aggregation on a per GNOS name basis

[[ ! -f /datastore/gnos_id.txt ]] && exit 0

addr=`ip a show eth0| grep inet|egrep -v inet6| awk '{print $2}' | cut -d"/" -f1`
sanitized_address=`echo $addr|sed 's/\./\-/g'`
gnos=`cat /datastore/gnos_id.txt`

rm -f /datastore/gnos_id.txt
rm /etc/sensu/conf.d/client.json

cat <<EOF >> /etc/sensu/conf.d/client.json
{
  "client": {
    "name": "${gnos}_${sanitized_address}",
    "address": "54.165.156.160",
    "subscriptions": [ "common", "ceph" ],
    "environment" : {
        "ansible_system_vendor": "Xen" ,
        "ansible_product_name": "HVM domU"
    }
  }
}
EOF

sudo service sensu-client restart 
