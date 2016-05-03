#!/bin/bash

source MoverArchivo.sh

#Variables de entorno provisorias
#ARRIDIR="../arribados"
#MAEDIR="../maestros"
#OKDIR="../aceptados"
#NOKDIR="../rechazados"

AMBIENTE_INICIALIZADO=false

# Evaluo que el ambiente haya sido inicializado.
if [[ ! -z $ARRIDIR ]] || [[ ! -z $MAEDIR ]] || [[ ! -z $OKDIR ]] || [[ ! -z $NOKDIR ]] || [[ ! -z $SLEEPTIME ]]
then
	AMBIENTE_INICIALIZADO=true
else
	echo "El ambiente no ha sido inicializado. Invoque a \". ./PrepararAmbiente <Path archivo configuracion>\""
	exit 1
fi

CONCESIONARIOS="$MAEDIR/concesionarios.mae"
FECHAS_ADJUDICACION="$MAEDIR/FechasAdj.mae"
SLEEPTIME=$SLEEPTIME
PROCESARENEJECUCION=false
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

function calcularFechaUltimoActo()
{
	fechaUltimoActo="19900101" # Seteo una fecha para calcular luego
	IFS="
	" #Determina el internal field separator

	while read -r fecha
	do
		# Verifica que sea una fecha valida
		if date -d "${fecha:6:4}${fecha:3:2}${fecha:0:2}" &> /dev/null
		then
			# Verifica que la fecha sea menor a la fecha actual
			if (( ($(date -d "${fecha:6:4}${fecha:3:2}${fecha:0:2}" +%s) < $(date +%s)) ))
			then
				# Verifica que la fecha guardada anteriormente no sea posterior a esta
				if (( ($(date -d "${fecha:6:4}${fecha:3:2}${fecha:0:2}" +%s) > $(date -d "$fechaUltimoActo" +%s)) ))
				then
					fechaUltimoActo="${fecha:6:4}${fecha:3:2}${fecha:0:2}"
				fi
			fi
		fi
	done < $FECHAS_ADJUDICACION
	#echo $fechaUltimoActo
}

function fechaValida()
{
	# Verifica que sea una fecha valida (existente)
	if date -d "${1:5:4}${1:9:2}${1:11:2}" &> /dev/null
	then
		#Verifica que sea menor o igual a la fecha del día.
		if (( ($(date -d "${1:5:4}${1:9:2}${1:11:2}" +%s) <= $(date +%s)) ))
		then
			# Verifica que sea mayor a la fecha del último acto de adjudicación.
			if (( ($(date -d "${1:5:4}${1:9:2}${1:11:2}" +%s) > $(date -d "$fechaUltimoActo" +%s)) ))
			then
				return 0
			fi
		fi
	fi
	return 1
}

function procesarNovedades
{
	listaNovedades=`ls -1 $ARRIDIR`
	archivoAceptado=false
	mensaje=""

	calcularFechaUltimoActo # Setea la variable fechaUltimoActo
				# Es calculada aqui porque sera la misma para todas las novedades de esta ejecucion

	for archivo in $listaNovedades
	do
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
						if [ ! `more "$ARRIDIR/$archivo" | wc -w` -eq 0 ] #Verifica que no sea un archivo vacio
						then
							mensaje="El archivo $archivo ha sido aceptado"
							archivoAceptado=true
						else
							mensaje="Se rechazo el archivo $archivo, este se encuentra vacio"
						fi
					else
						mensaje="Se rechazo el archivo $archivo, este posee una fecha invalida"
					fi
				else
					mensaje="Se rechazo el archivo $archivo, este posee un concesionario invalido"
				fi
			else
				mensaje="Se rechazo el archivo $archivo, este posee un formato de nombre invalido"
			fi
		else
			mensaje="Se rechazo el archivo $archivo, este no es un archivo de texto"
		fi

		# Muevo los archivos al directorio correspondiente y guardo el suceso en la bitacora
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

#-----------------------------------------------------------------------------------------------#
#----------------------------------------Bucle Principal----------------------------------------#
#-----------------------------------------------------------------------------------------------#

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
		#echo "Ciclo nro. $ciclo: No hay archivos de novedades"
	fi

	if hayArchivos $OKDIR
	then
		if ! $PROCESARENEJECUCION
		then
			./GrabarBitacora.sh "RecibirOfertas" "ProcesarOfertas corriendo bajo el no.: <Process Id de ProcesarOfertas>" "INFO"
			PROCESARENEJECUCION=true
			./ProcesarOfertas.sh &
		else
			./GrabarBitacora.sh "RecibirOfertas" "Invocación de ProcesarOfertas pospuesta para el siguiente ciclo" "INFO"
		fi
	fi
	sleep $SLEEPTIME
done

