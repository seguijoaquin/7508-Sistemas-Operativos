#!/bin/bash

source MoverArchivo.sh

#Variables de entorno provisorias
ARRIDIR="./Novedades"
MAEDIR="."
OKDIR="./Aceptados"
NOKDIR="./Rechazados"


CONCESIONARIOS="$MAEDIR/concesionarios.csv.xls"
SLEEPTIME=5 #TODO: Cambiar el tiempo
ciclo=0

function hayArchivos()
{
	cantidadArchivos=`ls -1 $1 | wc -w`

	if [ ! $cantidadArchivos -eq 0 ]
	then
		return 0 #Caso en el que existen archivos
	fi
	return 1
}

function esArchivoDeTexto()
{
	local archivo="$ARRIDIR/$1"
	local tipoArchivoValido=`file --mime-type $archivo | grep "text/plain$"`

	if [[ ! -z $tipoArchivoValido ]]
	then	# Archivo de texto valido
		return 0
	fi
	# El archivo no es de texto
	#echo "Archivo invalido es de tipo `file --mime-type $archivo`"
	return 1
}

function formatoNombreValido()
{
	nombreConFormatoValido=`echo $1 | grep "^[0-9]\{4\}_[0-9]\{8\}"`

	if [[ ! -z $nombreConFormatoValido ]]
	then # Posee formato valido
		return 0
	fi
	# Posee formato invalido
	return 1
}

function concesionarioValido()
{
	concesionario=`grep ${1:0:4} $CONCESIONARIOS`

	if [[ ! -z $concesionario ]]
	then # El concesionario existe
		return 0
	fi # El concesionario no existe
	return 1
}

function fechaValida()
{
	#TODO: Implementar
	return 0
}

function procesarNovedades
{
	listaNovedades=`ls -1 $ARRIDIR`
	archivoAceptado=false
	mensaje=""

	for archivo in $listaNovedades
	do
		#echo "Archivo encontrado: $archivo" 		#Borrar esta linea de prueba

		#Validar tipo de archivo
		if esArchivoDeTexto $archivo
		then
			#Validar nombre de archivo
			if formatoNombreValido $archivo
			then
				if concesionarioValido $archivo
				then
					if fechaValida $archivo
					then
						mensaje="El archivo $archivo ha sido aceptado"
						archivoAceptado=true
					else
						mensaje="Se rechazo el archivo $archivo, este posee una fecha invalida"
					fi
				else
					mensaje="Se rechazo el archivo $archivo, este posee un concesionario invalido"
				fi
			else
				mensaje="Se rechazo el archivo $archivo, este posee un nombre invalido"
			fi
		else
			mensaje="Se rechazo el archivo $archivo, este posee un formato invalido"
		fi

		# Guardo el suceso en la bitacora
		if ( ! $archivoAceptado )
		then
			MoverArchivos "$ARRIDIR/$archivo" "$NOKDIR/$archivo" "RecibirOfertas"
			./GrabarBitacora.sh "RecibirOfertas" "$mensaje" "WAR"
		else
			MoverArchivos "$ARRIDIR/$archivo" "$OKDIR/$archivo" "RecibirOfertas"
			./GrabarBitacora.sh "RecibirOfertas" "$mensaje" "INFO"
		fi
		archivoAceptado=false
		mensaje=""

	done
}

#-----------------------------------------------------------------------#
#----------------------------Bucle Principal----------------------------#
#-----------------------------------------------------------------------#

./GrabarBitacora.sh "RecibirOfertas" "                     NUEVA EJECUCION" "INFO"
while [[ true ]]
do
	let ciclo++
	./GrabarBitacora.sh "RecibirOfertas" "Ciclo Nro. $ciclo" "INFO"

	#Verifico que haya archivos
	if hayArchivos $ARRIDIR
	then
		#Proceso los archivos
		procesarNovedades
	else
		./GrabarBitacora.sh "RecibirOfertas" "Aun no se registran archivos recibidos." "INFO"
		echo "Ciclo nro. $ciclo: No hay archivos de novedades"
	fi
	sleep $SLEEPTIME
done

