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
			ARCHIVO_BITACORA=$LOGDIR/$INSTALL$EXT;;
		"PREPARARAMBIENTE")
			ARCHIVO_BITACORA=$LOGDIR/$PREPARARAMBIENTE$EXT;;
		"DETENERPROCESO")
			ARCHIVO_BITACORA=$LOGDIR/$DETENERPROCESO$EXT;;
		"DETERMINARGANADORES")
			ARCHIVO_BITACORA=$LOGDIR/$DETERMINARGANADORES$EXT;;
		"GENERARSORTEO")
			ARCHIVO_BITACORA=$LOGDIR/$GENERARSORTEO$EXT;;
		"LANZARPROCESO")
			ARCHIVO_BITACORA=$LOGDIR/$LANZARPROCESO$EXT;;
		"MOVERARCHIVO")
			ARCHIVO_BITACORA=$LOGDIR/$MOVERARCHIVO$EXT;;
		"PROCESAROFERTAS")
			ARCHIVO_BITACORA=$LOGDIR/$PROCESAROFERTAS$EXT;;
		"RECIBIROFERTAS")
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

function mostrarBitacora()
{
	grep "$TIPOEXT" $1 | sed -n "1,$LINEAS"p
}

# Inicializo las variables
PROCESO=""
LINEAS=""
TYPE=""

while getopts "p:l:t:" OPCION
do case "$OPCION" in
	p)PROCESO="$OPTARG";; 
	l)LINEAS="$OPTARG";;
	t)TYPE="$OPTARG";;
	?) echo "Opcion Inexistente: -$OPTARG" 
		exit 1;; 
esac
done

if [[  $PROCESO == "" || $LINEAS == "" ]]
then
	echo "No se han recibido los parametros necesarios:
		-p <nombre_proceso> : nombre del proceso que se desea mostrar su log
		-l <cant_lineas> : cantidad de lineas que se desean visualizar
		-t <tipo_loggeo> : tipo de entradas en la bitacora que se desean visualizar (INFO-WAR-ERR)"
	exit 1
else
	buscarBitacora
	buscarTipo
	mostrarBitacora $ARCHIVO_BITACORA
fi

