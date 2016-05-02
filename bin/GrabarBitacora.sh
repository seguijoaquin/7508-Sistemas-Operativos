#!/bin/bash

# TODO permitir dos parámetros; el tercero es opcional
#Verifico que tenga la cantidad de parametros necesarios
if [ $# -ne 3 ]
then
	echo "Cantidad de parametros invalidos"
	exit 1
fi

#El directorio de log para el instalador es .CONF/
#El directorio de log para el resto de los comandos es $LOGDIR

#Variables de entorno temporales hasta que haya script de seteo de variables de entorno
if [[ -z "$LOGDIR" ]]; then
	LOGDIR="./conf/"
fi
LOGEXT=".log"
USER="<log in del usuario>"
#fin variables temporales

#Archivo temporal
LOGFILETEMP="$LOGDIR/temp$LOGEXT"

#Cantidad de lineas
LOGLINE=50

#Tamaño del archivo de log
if [ -z $LOGSIZE ] #Si es para el instalador, se toma 400kb por defecto, si es para los archivos se toma de la configuración
then
	LOGMAX=409600
else
	LOGMAX=$(echo "scale=0 ; $LOGSIZE*1024" | bc -l)
fi

#Parametros
PCMD=$1  # Comando
PMSG=$2  # Mensaje
PTYPE=$3 # Tipo de mensaje

#Directorio Log para instalador
LOGFILEINS="GraLog.log"
LOGINS="./conf/$LOGFILEINS"

#Directorio Log para comandos
LOGCMD="$LOGDIR/$PCMD$LOGEXT"

#Tipos de LOG
INFO="INFORMACION"
WAR="WARNING"
ERR="ERROR"

#Selecciono el archivo donde se va a realizar el log
if [ $PCMD == "Installer" ]
then
	LOGFILE=$LOGINS
else
	LOGFILE=$LOGCMD
fi

#Si no existe el archivo, lo creo
mkdir -p $LOGDIR
touch $LOGFILE

#Selecciono el tipo de log
case $PTYPE in
	[Ii] )
		TYPE="-$INFO";;
	[Ww] )
		TYPE="-$WAR";;
	[Ee] )
		TYPE="-$ERR";;
	"INFO" )
		TYPE="-$INFO";;
	"WAR" )
		TYPE="-$WAR";;
	"ERR" )
		TYPE="-$ERR";;

	* )
		TYPE="-$INFO";;  #INFORMACION por defecto
esac

#Fecha y Hora actual
DATENOW=$(date +'%d-%m-%Y %H:%M:%S')

#Tamaño del log
LOGSIZE=$(stat -c%s "$LOGFILE")

if [ $LOGSIZE -gt $LOGMAX ]
then
	LINESIZE=`wc -l $LOGFILE | cut -d ' ' -f 1`
	ENDPOS=`expr $LINESIZE - $LOGLINE`
	sed "1,"${ENDPOS}"d" $LOGFILE >> $LOGFILETEMP
	rm $LOGFILE
	mv $LOGFILETEMP $LOGFILE
	echo "$DATENOW-$USER-$WAR-LOG Excedido" >> $LOGFILE
fi

#Escribo el log
echo "$DATENOW-$USER-$PCMD$TYPE-$PMSG" >> $LOGFILE

exit 0
