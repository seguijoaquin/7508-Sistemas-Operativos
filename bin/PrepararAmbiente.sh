#!/bin/bash

#Preparar ambiente.
#Se ejecuta manualmente cada vez que se inicia sesion
#Repara, si corresponde, la instalacion
#Invoca, si corresponde, el proceso RecibirOfertas

ERROR_COLOR='\033[0;31m'
NC='\033[0m' #no color
DIRECTORIO_COLOR='\e[93m'
ARCHIVO_COLOR='\e[93m'

function pause() {
	read -p "$*"
}

printError () {
	echo -e "${ERROR_COLOR}ERROR: $1 ${NC}"
}

# Funcion que da 0 si el ambiente fue inicializado y 1 si no
ambienteInicializado () {

	if [ "$AMBIENTE_INICIALIZADO" ]; then return 0; fi

	return 1

}

# Compruebo si un archivo existe y si no: lo informo y detengo el proceso
comprobarArchivo () {
	if [ ! -f "$1" ]; then
		printError "No existe el archivo: $1"
		return 1
	fi
	return 0
}

# Compruebo si un directorio existe y si no: lo informo y detengo el proceso
comprobarDirectorio () {
	if [ ! -d "$1" ]; then
		printError "No existe el directorio: $1"
		return 1
	fi
	return 0
}

#$1 tiene el contenido de la variable a chequear
#$2 tiene el nombre de la variable a chequear
comprobarVariable () {
	if [[ ! "$1" ]]; then
		printError "El valor de la variable $2 no fue asignada correctamente"
		return 1
	fi
	return 0
}

#$1: Archivo de configuracion
comprobarInstalacion () {
	echo "Comprobando la instalacion..."

	# $1: config file -------------
	comprobarArchivo "$1"

	if [ "$?" = 1 ]; then
		printError "El archivo de configuracion especificado es invalido: No existe el archivo"
		return 2
	fi

	GRUPO_INST=true

	CONFDIR_INST=true
	BINDIR_INST=true
	MAEDIR_INST=true
	OKDIR_INST=true
	NOKDIR_INST=true
	PROCDIR_INST=true
	INFODIR_INST=true
	LOGDIR_INST=true
	ARRIDIR_INST=true
	BACKUPDIR_INST=true

	LOGSIZE_INST=true
	LOGEXT_INST=true
	SLEEPTIME_INST=true

	#GRUPO
	VALOR=$( grep "^GRUPO.*$" "$1" | sed "s-\(^GRUPO=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	if $GRUPO_INST; then comprobarVariable "$VALOR" GRUPO; if [ "$?" = 1 ]; then GRUPO_INST=false; fi; fi
	if $GRUPO_INST; then comprobarDirectorio "$VALOR"; if [ "$?" = 1 ]; then GRUPO_INST=false; fi; fi

	#CONFDIR
	VALOR=$( grep "^CONFDIR.*$" "$1" | sed "s-\(^CONFDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	if $CONFDIR_INST; then comprobarVariable "$VALOR" CONFDIR; if [ "$?" = 1 ]; then CONFDIR_INST=false; fi; fi
	if $CONFDIR_INST; then comprobarDirectorio "$VALOR"; if [ "$?" = 1 ]; then CONFDIR_INST=false; fi; fi

	#BINDIR
	VALOR=$( grep "^BINDIR.*$" "$1" | sed "s-\(^BINDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	if $BINDIR_INST; then comprobarVariable "$VALOR" BINDIR; if [ "$?" = 1 ]; then BINDIR_INST=false; fi; fi
	if $BINDIR_INST; then comprobarDirectorio "$VALOR"; if [ "$?" = 1 ]; then BINDIR_INST=false; fi; fi

	if $BINDIR_INST; then comprobarArchivo "$VALOR/RecibirOfertas.sh"; if [ "$?" = 1 ]; then BINDIR_INST=false; fi; fi
	if $BINDIR_INST; then comprobarArchivo "$VALOR/ProcesarOfertas.sh"; if [ "$?" = 1 ]; then BINDIR_INST=false; fi; fi
	if $BINDIR_INST; then comprobarArchivo "$VALOR/GenerarSorteo.sh"; if [ "$?" = 1 ]; then BINDIR_INST=false; fi; fi
	if $BINDIR_INST; then comprobarArchivo "$VALOR/DeterminarGanadores.pl"; if [ "$?" = 1 ]; then BINDIR_INST=false; fi; fi
	if $BINDIR_INST; then comprobarArchivo "$VALOR/GrabarBitacora.sh"; if [ "$?" = 1 ]; then BINDIR_INST=false; fi; fi
	if $BINDIR_INST; then comprobarArchivo "$VALOR/MoverArchivo.sh"; if [ "$?" = 1 ]; then BINDIR_INST=false; fi; fi
	if $BINDIR_INST; then comprobarArchivo "$VALOR/LanzarProceso.sh"; if [ "$?" = 1 ]; then BINDIR_INST=false; fi; fi
	if $BINDIR_INST; then comprobarArchivo "$VALOR/DetenerProceso.sh"; if [ "$?" = 1 ]; then BINDIR_INST=false; fi; fi

	#MAEDIR
	VALOR=$( grep "^MAEDIR.*$" "$1" | sed "s-\(^MAEDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	if $MAEDIR_INST; then comprobarVariable "$VALOR" MAEDIR; if [ "$?" = 1 ]; then MAEDIR_INST=false; fi; fi
	if $MAEDIR_INST; then comprobarDirectorio "$VALOR"; if [ "$?" = 1 ]; then MAEDIR_INST=false; fi; fi
	if $MAEDIR_INST; then comprobarArchivo "$VALOR/concesionarios.mae"; if [ "$?" = 1 ]; then MAEDIR_INST=false; fi; fi
	if $MAEDIR_INST; then comprobarArchivo "$VALOR/FechasAdj.mae"; if [ "$?" = 1 ]; then MAEDIR_INST=false; fi; fi
	if $MAEDIR_INST; then comprobarArchivo "$VALOR/grupos.mae"; if [ "$?" = 1 ]; then MAEDIR_INST=false; fi; fi
	if $MAEDIR_INST; then comprobarArchivo "$VALOR/temaK_padron.mae"; if [ "$?" = 1 ]; then MAEDIR_INST=false; fi; fi

	#OKDIR
	VALOR=$( grep "^OKDIR.*$" "$1" | sed "s-\(^OKDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	if $OKDIR_INST; then comprobarVariable "$VALOR" OKDIR; if [ "$?" = 1 ]; then OKDIR_INST=false; fi; fi
	if $OKDIR_INST; then comprobarDirectorio "$VALOR"; if [ "$?" = 1 ]; then OKDIR_INST=false; fi; fi

	#NOKDIR
	VALOR=$( grep "^NOKDIR.*$" "$1" | sed "s-\(^NOKDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	if $NOKDIR_INST; then comprobarVariable "$VALOR" NOKDIR; if [ "$?" = 1 ]; then NOKDIR_INST=false; fi; fi
	if $NOKDIR_INST; then comprobarDirectorio "$VALOR"; if [ "$?" = 1 ]; then NOKDIR_INST=false; fi; fi

	#PROCDIR
	VALOR=$( grep "^PROCDIR.*$" "$1" | sed "s-\(^PROCDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	if $PROCDIR_INST; then comprobarVariable "$VALOR" PROCDIR; if [ "$?" = 1 ]; then PROCDIR_INST=false; fi; fi
	if $PROCDIR_INST; then comprobarDirectorio "$VALOR"; if [ "$?" = 1 ]; then PROCDIR_INST=false; fi; fi

	#INFODIR
	VALOR=$( grep "^INFODIR.*$" "$1" | sed "s-\(^INFODIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	if $INFODIR_INST; then comprobarVariable "$VALOR" INFODIR; if [ "$?" = 1 ]; then INFODIR_INST=false; fi; fi
	if $INFODIR_INST; then comprobarDirectorio "$VALOR"; if [ "$?" = 1 ]; then INFODIR_INST=false; fi; fi

	#LOGDIR
	VALOR=$( grep "^LOGDIR.*$" "$1" | sed "s-\(^LOGDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	if $LOGDIR_INST; then comprobarVariable "$VALOR" LOGDIR; if [ "$?" = 1 ]; then LOGDIR_INST=false; fi; fi
	if $LOGDIR_INST; then comprobarDirectorio "$VALOR"; if [ "$?" = 1 ]; then LOGDIR_INST=false; fi; fi

	#ARRIDIR
	VALOR=$( grep "^ARRIDIR.*$" "$1" | sed "s-\(^ARRIDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	if $ARRIDIR_INST; then comprobarVariable "$VALOR" ARRIDIR; if [ "$?" = 1 ]; then ARRIDIR_INST=false; fi; fi
	if $ARRIDIR_INST; then comprobarDirectorio "$VALOR"; if [ "$?" = 1 ]; then ARRIDIR_INST=false; fi; fi

	#BACKUPDIR
	VALOR=$( grep "^BACKUPDIR.*$" "$1" | sed "s-\(^BACKUPDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	if $BACKUPDIR_INST; then comprobarVariable "$VALOR" BACKUPDIR; if [ "$?" = 1 ]; then BACKUPDIR_INST=false; fi; fi
	if $BACKUPDIR_INST; then comprobarDirectorio "$VALOR"; if [ "$?" = 1 ]; then BACKUPDIR_INST=false; fi; fi


	#Variables

	#LOGSIZE
	VALOR=$( grep "^LOGSIZE.*$" "$1" | sed "s-\(^LOGSIZE=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	if $LOGSIZE_INST; then comprobarVariable "$VALOR" LOGSIZE; if [ "$?" = 1 ]; then LOGSIZE_INST=false; fi; fi

	#LOGEXT
	VALOR=$( grep "^LOGEXT.*$" "$1" | sed "s-\(^LOGEXT=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	if $LOGEXT_INST; then comprobarVariable "$VALOR" LOGEXT; if [ "$?" = 1 ]; then LOGEXT_INST=false; fi; fi

	#SLEEPTIME
	VALOR=$( grep "^SLEEPTIME.*$" "$1" | sed "s-\(^SLEEPTIME=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	if $SLEEPTIME_INST; then comprobarVariable "$VALOR" SLEEPTIME; if [ "$?" = 1 ]; then SLEEPTIME_INST=false; fi; fi

	if $GRUPO_INST && $CONFDIR_INST && $BINDIR_INST && $MAEDIR_INST && $OKDIR_INST && $NOKDIR_INST && $PROCDIR_INST && $INFODIR_INST && $LOGDIR_INST && $ARRIDIR_INST && $LOGSIZE_INST $LOGEXT_INST && $SLEEPTIME_INST; then
		return 0
	 fi

	return 1

}

#Recibe como primer parametro la ruta del archivo CIPAK.cnf
#Segundo parametro es la ruta de scripts de respaldo
copiarArchivos () {
	if ( "$BACKUPDIR_INST" ); then
		BACKUPDIR=$( grep "^BACKUPDIR.*$" "$1" | sed "s-\(^BACKUPDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
		export BACKUPDIR
	else
		return 1
	fi

	if ( "$BINDIR_INST" ); then
		if ( "$GRUPO_INST"); then
			GRUPO=$( grep "^GRUPO.*$" "$1" | sed "s-\(^GRUPO=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
			export GRUPO
			BINDIR=$( grep "^BINDIR.*$" "$1" | sed "s-\(^BINDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
			export BINDIR
			#TODO: Copiar desde backupdir a bindir
			for i in $(ls "$BINDIR"/*.sh)
			 do
				cp "$GRUPO$BACKUPDIR/$i" "$GRUPO$BINDIR/$i"
			done
		fi
	else
		return 1
	fi
	return 0
}

# En $1 recibe la ruta del archivo de configuracion CIPAK.cfg
repararInstalacion () {
	printError "La instalacion no fue realizada correctamente"
	echo "Desea reparar la instalacion? (1 o 2)"

	select respuesta in Si No
	do
		case $respuesta in

			Si)
				if (! "$BACKUPDIR_INST" ) then
					printError "No se puede reparar la instalacion. Faltan archivos de respaldo"
					echo -e "Por favor realice nuevamente la instalacion invocando a \"\$INSTALL.sh\"\n"
					return 1
				fi

				copiarArchivos "$1"

				if [[ "$?" = 1 ]]; then
					printError "No se pudieron copiar algunos archivos"
					echo -e "Por favor realice nuevamente la instalacion invocando a \"\$INSTALL.sh\"\n"
					return 1
				fi
				return 0 ;;

			No)	printError "El ambiente no pudo iniciarse correctamente"
				echo "La instalacion no ha sido reparada"
				return 1 ;;

			*) echo "La respuesta solicitada no es valida por favor ingrese nuevamente: Recuerde que las opciones son 1 o 2 respectivamente"
		esac
	done
}

#$1: Archivo al cual le quiero cambiar los permisos
#$2: Permisos por ejemplo "+x"
setearPermiso () {
	{ chmod "$2" "$1"
	} || {
	printError "No se pudieron setear los permisos de \"$1\" correctamente"
	return 1
	}
}

#$1: Directorio al cual le quiero cambiar los permisos a todos sus archivos
#$2: Permisos por ejemplo "+x"
setearPermisosDeUnDirectorio () {
	{ chmod "$2" -R "$1"
	} || {
	printError "No se pudieron setear los permisos de \"$1\" correctamente"
	return 1
	}
}

seteoDePermisos () {
	#Seteo permiso de lectura al archivo de configuracion
	setearPermiso "$1" "+r"

	#BINDIR: Agrego permisos de ejecucion a todos los archivos del directorio.
	VALOR=$( grep "^BINDIR.*$" "$1" | sed "s-\(^BINDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	setearPermisosDeUnDirectorio "$VALOR" "+x"

	#MAEDIR: Agrego permisos de lectura a todos los archivos de MAEDIR
	VALOR=$( grep "^MAEDIR.*$" "$1" | sed "s-\(^MAEDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	setearPermisosDeUnDirectorio "$VALOR" "+r"

	#EN TODOS LOS DEMAS SI HAY ARCHIVOS LES DOY PERMISOS DE LECTURA

	#OKDIR
	VALOR=$( grep "^OKDIR.*$" "$1" | sed "s-\(^OKDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	setearPermisosDeUnDirectorio "$VALOR" "+r"

	#BACKUPDIR
	VALOR=$( grep "^BACKUPDIR.*$" "$1" | sed "s-\(^BACKUPDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	setearPermisosDeUnDirectorio "$VALOR" "+r"

	#NOKDIR
	VALOR=$( grep "^NOKDIR.*$" "$1" | sed "s-\(^NOKDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	setearPermisosDeUnDirectorio "$VALOR" "+r"

	#PROCDIR
	VALOR=$( grep "^PROCDIR.*$" "$1" | sed "s-\(^PROCDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	setearPermisosDeUnDirectorio "$VALOR" "+r"

	#INFODIR
	VALOR=$( grep "^INFODIR.*$" "$1" | sed "s-\(^INFODIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	setearPermisosDeUnDirectorio "$VALOR" "+r"

	#LOGDIR
	VALOR=$( grep "^LOGDIR.*$" "$1" | sed "s-\(^LOGDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	setearPermisosDeUnDirectorio "$VALOR" "+r"
	setearPermisosDeUnDirectorio "$VALOR" "+w"

	#ARRIDIR
	VALOR=$( grep "^ARRIDIR.*$" "$1" | sed "s-\(^ARRIDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	setearPermisosDeUnDirectorio "$VALOR" "+r"

	return 0
}

levantarVariablesDesdeElArchivo () {
	echo "Levantando variables de ambiente desde el archivo de configuracion..."
	#GRUPO
	GRUPO=$( grep "^GRUPO.*$" "$1" | sed "s-\(^GRUPO=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	export GRUPO

	#CONFDIR
	CONFDIR=$( grep "^CONFDIR.*$" "$1" | sed "s-\(^CONFDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	export CONFDIR

	#BINDIR
	BINDIR=$( grep "^BINDIR.*$" "$1" | sed "s-\(^BINDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	export BINDIR

	#BACKUPDIR
	BACKUPDIR=$( grep "^BACKUPDIR.*$" "$1" | sed "s-\(^BACKUPDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	export BACKUPDIR

	#PATH
	PATH="$PATH:$BINDIR"
	export PATH

	#MAEDIR
	MAEDIR=$( grep "^MAEDIR.*$" "$1" | sed "s-\(^MAEDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	export MAEDIR

	#OKDIR
	OKDIR=$( grep "^OKDIR.*$" "$1" | sed "s-\(^OKDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	export OKDIR

	#NOKDIR
	NOKDIR=$( grep "^NOKDIR.*$" "$1" | sed "s-\(^NOKDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	export NOKDIR

	#PROCDIR
	PROCDIR=$( grep "^PROCDIR.*$" "$1" | sed "s-\(^PROCDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	export PROCDIR

	#INFODIR
	INFODIR=$( grep "^INFODIR.*$" "$1" | sed "s-\(^INFODIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	export INFODIR

	#LOGDIR
	LOGDIR=$( grep "^LOGDIR.*$" "$1" | sed "s-\(^LOGDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	export LOGDIR

	#ARRIDIR
	ARRIDIR=$( grep "^ARRIDIR.*$" "$1" | sed "s-\(^ARRIDIR=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	export ARRIDIR

	#Variables

	#LOGSIZE
	LOGSIZE=$( grep "^LOGSIZE.*$" "$1" | sed "s-\(^LOGSIZE=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	export LOGSIZE

	#SLEEPTIME
	SLEEPTIME=$( grep "^SLEEPTIME.*$" "$1" | sed "s-\(^SLEEPTIME=\)\([^=]*\)\(=[^=]*=[^=]*$\)-\2-" )
	export SLEEPTIME

	return 0
}

muestraYlogueoIndividual () {
	CONTENIDO=$(ls "$1")
	MSG="$2 ${DIRECTORIO_COLOR} $1 ${NC}"

	echo -e "$MSG"
	GrabarBitacora.sh PrepararAmbiente "$2 $1" "INFO"

	if [ -n "$CONTENIDO" ]; then
		echo "Archivos:"
		GrabarBitacora.sh PrepararAmbiente "Archivos:" "INFO"

		for archivo in $CONTENIDO
		do
			echo -e "${ARCHIVO_COLOR} $archivo ${NC}"
			GrabarBitacora.sh PrepararAmbiente "$archivo" "INFO"
		done
	fi

	return 0
}

mostrarYloguearVariables () {
	muestraYlogueoIndividual "$CONFDIR" "Directorio de Configuracion:" "CONFDIR"
	muestraYlogueoIndividual "$BINDIR" "Directorio de Ejecutables:" "BINDIR"
	muestraYlogueoIndividual "$BACKUPDIR" "Directorio de backup:" "BACKUPDIR"
	muestraYlogueoIndividual "$MAEDIR" "Directorio de Maestros y Tablas:" "MAEDIR"
	muestraYlogueoIndividual "$ARRIDIR" "Directorio de recepcion de archivos de novedades:" "ARRIDIR"
	muestraYlogueoIndividual "$OKDIR" "Directorio de Archivos aceptados:" "OKDIR"
	muestraYlogueoIndividual "$PROCDIR" "Directorio de Archivos procesados:" "PROCDIR"
	muestraYlogueoIndividual "$INFODIR" "Directorio de Archivos de Reportes:" "INFODIR"
	muestraYlogueoIndividual "$LOGDIR" "Directorio de Archivos de Log:" "LOGDIR"
	muestraYlogueoIndividual "$NOKDIR" "Directorio de Archivos Rechazados:" "NOKDIR"

	echo "Estado del Sistema: INICIALIZADO"
	GrabarBitacora.sh PrepararAmbiente "Estado del Sistema: INICIALIZADO" "INFO"
}

arranqueRecibirOfertas () {
	echo "¿Desea comenzar a recibir ofertas? ( ingrese 1 o 2 )"

	select respuesta in Si No
	do
		case $respuesta in

			Si)	psOut=$(ps -eo pid,args) # correr separado para que ps no muestre a grep corriendo
				PROCESO=$( echo "$psOut" | grep "RecibirOfertas.sh" )
				if [ -n "$PROCESO" ]; then
					echo "Ya existe un proceso RecibirOfertas corriendo"
					return 0
				fi

				LanzarProceso.sh -i RecibirOfertas

				SAVEIFS=$IFS
				IFS=" "
				psOut=$(ps -eo pid,args) # correr separado para que ps no muestre a grep corriendo
				RecibirOfertas_ID=$( echo "$psOut" | grep "RecibirOfertas" )
				RecibirOfertas_ID=( $RecibirOfertas_ID )
				RecibirOfertas_ID=${RecibirOfertas_ID[0]}

				IFS=$SAVEIFS

				MSJ="RecibirOfertas corriendo bajo el no.: <$RecibirOfertas_ID>"
				echo $MSJ
				echo "Para detenerlo invocar el siguiente comando:"
				echo "DetenerProceso.sh"
				GrabarBitacora.sh PrepararAmbiente "$MSJ" "INFO"

				return 0 ;;

			No)	echo "El proceso RecibirOfertas no se iniciara"
				echo "Puede iniciarlo manualmente a traves del comando:"
				echo "LanzarProceso.sh"
				echo "y para luego detenerlo invocar el siguiente comando:"
				echo "DetenerProceso.sh"
				return 0 ;;

			*) echo "La respuesta solicitada no es valida por favor ingrese nuevamente: Recuerde que las opciones son 1 o 2 respectivamente"
		esac
	done
}

# Chequea que el script corra de la forma '. PrepararAmbiente.sh'
chequearSourced() {
	if [[ $0 == $BASH_SOURCE ]]; then
		printError "Este script debe ser llamado de la forma '. PrepararAmbiente.sh' para configurar las variables de entorno correctamente"
		exit 1
	fi
}

###############################################################################
#$1: Contiene el archivo de configuracion con su path ej:"/home/.../CIPAK.conf"

#-------------------- CODIGO PRINCIPAL ----------------------------------------

clear

# A partir de este punto usaremos return en lugar de exit ya que estamos 'sourceados'
chequearSourced

# Funcion que devuelve 0 si no fue inicializado u otro numero si lo fue
ambienteInicializado

# Veo cual fue el resultado de la funcion anterior
if [ "$?" =  1 ]; then

	#Input
	if [[ ! "$1" ]]; then
		printError "Los parametros de entrada no fueron introducidos correctamente"
		echo -e "Uso: PrepararAmbiente.sh CONF \n"
		echo -e "CONF es la ruta al archivo de configuración, que puede ser generado por INSTALL.sh."
		echo -e "Por ejemplo \"/home/usuario/CIPAK/CIPAK.cnf\" \n"
		pause 'Press [Enter] key to continue...'
		return 1
	fi


	CONFIG_FILE=$1

	# Ambiente no inicializado

	comprobarInstalacion "$CONFIG_FILE"

	VALOR_RETORNO="$?"

	if [ "$VALOR_RETORNO" = 1 ]; then
		repararInstalacion "$CONFIG_FILE"
		pause 'Press [Enter] key to continue...'
		return 1

	elif [ "$VALOR_RETORNO" = 2 ]; then
		#Archivo de configuracion invalido
		echo -e "Por favor realice nuevamente la instalacion invocando a \"\$INSTALL.sh\"\n"
		pause 'Press [Enter] key to continue...'
		return 1
	fi

	seteoDePermisos "$CONFIG_FILE"

	if [ "$?" = 1 ]; then
		return 1
	fi

	levantarVariablesDesdeElArchivo "$CONFIG_FILE"

	mostrarYloguearVariables

	#Inicio RecibirOfertas
	arranqueRecibirOfertas

	AMBIENTE_INICIALIZADO=true

	pause 'Press [Enter] key to continue...'

else # -------------------------------------------

	# Ambiente inicializado

	MSJ="Ambiente ya inicializado, para reiniciar termine la sesion e ingrese nuevamente"

	echo -e $MSJ"\n"

	# Log del mensaje y sus respectivos datos.
	GrabarBitacora.sh "PrepararAmbiente" "$MSJ" "INFO"

	pause 'Press [Enter] key to continue...'

fi
