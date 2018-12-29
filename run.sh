#!/bin/bash

SLEEP_DURATION="1m"

echo -e "Enter your gcloud username: \c"

read USERNAME

echo "[INFO] Will run Ansible with username: $USERNAME..."

(cd ./terraform && terraform apply -auto-approve && sleep $SLEEP_DURATION && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u $USERNAME -i ../ansible/hosts ../ansible/playbook.yml)

if [ "$?" -eq 0 ];
  then 
    echo -e "\033[32m [INFO] Success"
  else 
    echo -e "\033[31m [ERROR] Failure"
fi

(tput init) 
