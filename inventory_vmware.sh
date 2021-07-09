#!/bin/bash

#==============================================================================#
# title           :create_inventory.sh                                         #
# description     :Este script cria o inventario automatizado para o ansible.  #
# author	  :Arthur Vanzelli                                           #
# date            :20190917                                                    #
# credits	  :Marcio Moraes                                              #
# version         :0.1                                                         #
# usage		  :bash create_inventory.sh                                    #
# notes           :Necessario curl instalado para utilizar este script.        #
# bash_version    :4.2.46(2)-release                                           #
#==============================================================================#

set -x


HEADER_POST1="Content-Type: application/json"
HEADER_POST2="Accept: application/json"
HEADER_POST3="vmware-use-header-authn: test"
HEADER_POST4="vmware-api-session-id: null"
HEADER_GET1="Accept:application/json"
HEADER_GET2="vmware-api-session-id"
URL_POST="https://SEU_VCENTER/rest/com/vmware/cis/session"
CRED="SUA_CREDENCIAL"
URL_GET="https://SEU_VCENTER/rest/vcenter/vm?filter.power_states.1=POWERED_ON"
INPUT_FILE="/tmp/input1.tmp"
OUTPUT_FILE_TMP="/tmp/hosts_tmp"
OUTPUT_FILE="/tmp/hosts"
OUTPUT_FILE_DEST="/etc/ansible/hosts_zabbix"

echo "Coleta o token"
token=$(curl -k -X POST -H "${HEADER_POST1}" -H "${HEADER_POST2}" -H "${HEADER_POST3}" -H "${HEADER_POST4}" -u "${CRED}" "${URL_POST}" | cut -d":" -f2 | sed "s/\"//g" | sed 's/\}//g')
pause 5
echo "Coletando dados das VMs linux"
list=$(sudo curl -sik -H "${HEADER_GET1}" -H "${HEADER_GET2}:${token}" --digest -X GET "${URL_GET}" | tail -1 | jq | grep name | awk '{print $2}' | tr "\"" " " | tr "," " " | sed "s/\ //g" | sort -h)
echo ${list} | tr " " "\n" >> ${INPUT_FILE}

echo "[DEV]">>${OUTPUT_FILE_TMP}
while read VAR_LINHA
do
        echo $VAR_LINHA|grep ^d>>${OUTPUT_FILE_TMP}
done<${INPUT_FILE}

echo "[HOM]">>${OUTPUT_FILE_TMP}
while read VAR_LINHA
do
        echo $VAR_LINHA|grep ^h>>${OUTPUT_FILE_TMP}
done<${INPUT_FILE}


echo "[PROD]">>${OUTPUT_FILE_TMP}
while read VAR_LINHA
do
        echo $VAR_LINHA|grep ^p>>${OUTPUT_FILE_TMP}
done<${INPUT_FILE}

$(cat ${OUTPUT_FILE_TMP} | sort -h | egrep -v 'NSX|V|restored|lab|^pa|^pw|^hw|^dw|Edge|xxxxxxxxxxxxxxxxx' | uniq > /tmp/hosts)

sed -i -e '1i\' -e '[DEV]' ${OUTPUT_FILE}

sudo cp -a ${OUTPUT_FILE} ${OUTPUT_FILE_DEST}

rm -rf ${INPUT_FILE} ${OUTPUT_FILE_TMP} ${OUTPUT_FILE}

exit

