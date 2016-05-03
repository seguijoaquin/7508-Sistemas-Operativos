#!/bin/bash

#LOGDIR="../bitacoras" # Variable que se crea en PrepararAmbiente.

# Nombres de Archivos segun proceso
INSTALL="Installer"
PREPARARAMBIENTE="PrepararAmbiente"
DETENERPROCESO="DetenerProceso"
DETERMINARGANADORES="DeterminarGanadores"
GENERARSORTEO="GenerarSorteo"
LANZARPROCESO="LanzarProceso"
MOVERARCHIVO="MoverArchivo"
PROCESAROFERTAS="ProcesarOfertas"
RECIBIROFERTAS="RecibirOfertas"
EXT=".log"

function buscarBitacora()
{
	procesoMayus=`echo $PROCESO | tr [[:lower:]] [[:upper:]]`
	case $procesoMayus in
		"INSTALL")
			PROCESO=$INSTALL
			ARCHIVO_BITACORA=$LOGDIR/$INSTALL$EXT;;
		"PREPARARAMBIENTE")
			PROCESO=$PREPARARAMBIENTE
			ARCHIVO_BITACORA=$LOGDIR/$PREPARARAMBIENTE$EXT;;
		"DETENERPROCESO")
			PROCESO=$DETENERPROCESO
			ARCHIVO_BITACORA=$LOGDIR/$DETENERPROCESO$EXT;;
		"DETERMINARGANADORES")
			PROCESO=$DETERMINARGANADORES
			ARCHIVO_BITACORA=$LOGDIR/$DETERMINARGANADORES$EXT;;
		"GENERARSORTEO")
			PROCESO=$GENERARSORTEO
			ARCHIVO_BITACORA=$LOGDIR/$GENERARSORTEO$EXT;;
		"LANZARPROCESO")
			PROCESO=$LANZARPROCESO
			ARCHIVO_BITACORA=$LOGDIR/$LANZARPROCESO$EXT;;
		"MOVERARCHIVO")
			PROCESO=$MOVERARCHIVO
			ARCHIVO_BITACORA=$LOGDIR/$MOVERARCHIVO$EXT;;
		"PROCESAROFERTAS")
			PROCESO=$PROCESAROFERTAS
			ARCHIVO_BITACORA=$LOGDIR/$PROCESAROFERTAS$EXT;;
		"RECIBIROFERTAS")
			PROCESO=$RECIBIROFERTAS
			ARCHIVO_BITACORA=$LOGDIR/$RECIBIROFERTAS$EXT;;
		*)
			echo "El proceso especificado no existe"
			exit 1;;
	esac
}

function buscarTipo()
{
	tipoMayus=`echo $TYPE | tr [[:lower:]] [[:upper:]]`
	case $tipoMayus in
		"INFO")
			TIPOEXT="INFORMACION";;
		"ERR")
			TIPOEXT="ERROR";;
		"WAR")
			TIPOEXT="WARNING";;
		*)
			TIPOEXT=""
	esac
}

function existenciaBitacora() {
	if [[ ! -f $ARCHIVO_BITACORA ]]
	then
		echo "No existe Log para $PROCESO"
	else
		EXISTE_BITACORA=true
	fi
}

function mostrarBitacora()
{
	IFS="
	"
	fechaAnt=""
	fechaAct=""
	horaAnt=""
	horaAct=""
	echo "
	Bitacora del proceso: $PROCESO
	"
	for i in `grep "$TIPOEXT" $1 | grep "$2" | sed -n "1,$LINEAS"p | sed s/"$PROCESO-"/""/`
	do
		fechaAct=${i:0:10}
		horaAct=${i:11:5}
		if [[ $fechaAnt == $fechaAct ]]
		then
			if [[ $horaAnt == $horaAct ]]
			then
				echo "                  ${i:20:-1}"
			else
				echo "            ${i:11:5}-${i:20:-1}"
			fi
			
		else
			echo " $fechaAct ${i:11:5}-${i:20:-1}"
		fi
		fechaAnt=$fechaAct
		horaAnt=$horaAct
	done
}

# Inicializo las variables
PROCESO=""
LINEAS=""
TYPE=""
STRING=""
EXISTE_BITACORA=false

while getopts "p:l:t:s:" OPCION
do case "$OPCION" in
	p)PROCESO="$OPTARG";; 
	l)LINEAS="$OPTARG";;
	t)TYPE="$OPTARG";;
	s)STRING="$OPTARG";;
	?) echo "Opcion Inexistente: -$OPTARG" 
		exit 1;; 
esac
done

if [[ $PROCESO == "" || $LINEAS == "" ]]
then
	echo "No se han recibido los parametros necesarios:
		-p <nombre_proceso> : nombre del proceso que se desea mostrar su log
		-l <cant_lineas> : cantidad de lineas que se desean visualizar
		-t <tipo_loggeo> : tipo de entradas en la bitacora que se desea visualizar (INFO-WAR-ERR)
		-s <string_a_buscar> : string a buscar en la bitacora que se desea visualizar"
	exit 1
else
	buscarBitacora
	buscarTipo
	existenciaBitacora
	if $EXISTE_BITACORA
	then mostrarBitacora $ARCHIVO_BITACORA $STRING;
	fi
fi

