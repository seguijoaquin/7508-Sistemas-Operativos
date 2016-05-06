#!/bin/bash


ROJO='\033[0;31m'
NC='\033[0m' #no color
VERDE='\e[0;32m'
AMARILLO='\e[93m'

clear

	if [ -z "$AMBIENTE_INICIALIZADO" ]; then
    echo -e "${ROJO}ERROR: Ambiente no inicializado${NC}"
    exit 1;
  fi

echo -e "${VERDE}Imprimo variables de ambiente${NC}"
echo "-----------------------------"
echo -e "${AMARILLO}CONFDIR${NC}"
echo "$CONFDIR"
echo -e "${AMARILLO}BINDIR${NC}"
echo "$BINDIR"
echo -e "${AMARILLO}BACKUPDIR${NC}"
echo "$BACKUPDIR"
echo -e "${AMARILLO}MAEDIR${NC}"
echo "$MAEDIR"
echo -e "${AMARILLO}ARRIDIR${NC}"
echo "$ARRIDIR"
echo -e "${AMARILLO}OKDIR${NC}"
echo "$OKDIR"
echo -e "${AMARILLO}PROCDIR${NC}"
echo "$PROCDIR"
echo -e "${AMARILLO}INFODIR${NC}"
echo "$INFODIR"
echo -e "${AMARILLO}LOGDIR${NC}"
echo "$LOGDIR"
echo -e "${AMARILLO}NOKDIR${NC}"
echo "$NOKDIR"
echo -e "${AMARILLO}AMBIENTE_INICIALIZADO${NC}"
echo "$AMBIENTE_INICIALIZADO"
