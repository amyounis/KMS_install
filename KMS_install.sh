#! /bin/bash

clear

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}" 
   exit 1
fi


function print {
  ScreenWidth=`tput cols`
  Arg=$@
  ArgSize=${#Arg}
  let "Rem = $ScreenWidth - $ArgSize - 1"
  printf "\n" ; printf "$Arg " ; printf '*%.0s' $(seq 1 $Rem) ; printf "\n" 
}

function isinstalled {
  if yum list installed "$@" >/dev/null 2>&1; then
    true
  else
    false
  fi
}


print "Testing Internet Connection"
if ! ping  -c 4 8.8.8.8 &>/dev/null
then 
  echo -e "${RED}please insure that your machine is connected to internet${NC}" && exit 1
else
  echo -e "${GREEN}OK${NC}"
fi

print "Installing EPEL Repo"
if ! isinstalled epel-release
then 
  yum -q -y install epel-release && echo -e "${GREEN}OK${NC}"
else
  echo -e "${GREEN}OK${NC}"
fi

print "Installing GIT"
if ! isinstalled git
then 
  yum -q -y install git && echo -e "${GREEN}OK${NC}"
else
  echo -e "${GREEN}OK${NC}"
fi

print "Installing Ansible"
if ! isinstalled ansible
then
  yum -q -y install ansible && echo -e "${GREEN}OK${NC}"
else
  echo -e "${GREEN}OK${NC}"
fi

print "Clone KMS_install Repo"
if [ ! -d KMS_install ] 
then
  git clone https://github.com/amyounis/KMS_install.git && cd KMS_install && echo -e "${GREEN}OK${NC}"
else
  cd KMS_install && echo -e "${GREEN}OK${NC}"
fi

print "Running Ansible Playbook"
ansible-playbook site.yml -i hosts
