#!/bin/bash

set -x

# FUNCAO VERIFICA SE ARQUIVO EXISTE

while true
do

CHECK_FILE () {

while [ $( ls -l /opt/aplicacoes/contabrm/recebido/*.zip 2> /dev/null ; echo $? ) = 2 ]
  do
    echo "Nao existem arquivos para serem processados"
    sleep 3 
  done
}

CHECK_FILE

if [ $(/usr/bin/unzip -t /opt/aplicacoes/contabrm/recebido/*.zip 2> /dev/null ; echo $?) = 0 ]
  then 
    echo "ARQUIVO VALIDO"
    sleep 10
    echo "Executa contabrm.sh" 
    DT=`date "+%Y%m%d-%H%M%S"`
    DT1=`date "+%M%S"`
    DATA=`date "+%Y %m %d"`
    DTDHS=`date +"%d%H%M%S"`
    PROC_LOG1=/tmp/calculo_estudos_contabrm
    PATH_HOME=/opt/aplicacoes/contabrm
 
    cd /opt/aplicacoes/contabrm/recebido

    ID=`echo "$DTDHS"`
    mkdir "$ID"
    ARQ=`ls -1 *.zip`
    mv $ARQ "$ID"  
    ARQN=`echo $ARQ`
    CB=`ls -t $PATH_HOME/recebido/$ARQN | cut -d'/' -f9 | tail -1`
    CB=$ARQN
    ARQ=`echo $CB | awk -F '.zip' '{ print $1 }'`
    echo $ARQ >> $PATH_HOME/recebido/$ID/flag_$DT
    unzip $PATH_HOME/recebido/$ID/$CB -d $PATH_HOME/recebido/$ID/$ARQ
    cd /opt/aplicacoes/contabrm/recebido/$ID/$ARQ
       for x in `ls -1 *`
         do newname=`echo $x |tr [A-Z] [a-z]`; mv $x $newname
         done
    echo "INSERIR CURL DO DENIS"
    sleep 5
    CHECK_FILE
  else
	echo "ARQUIVO ZIP DANIFICADO INSIRA UM ARQUIVO VALIDO !!!!!!!"
    sleep 10

fi
done
