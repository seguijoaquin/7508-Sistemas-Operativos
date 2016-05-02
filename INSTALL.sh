#!/bin/bash
#Instalador CIPAK - Grupo 7
#*************************** Variables ***************************
ACTUALDIR="./"

LOGFILEINS="install.log"
GRUPO="${1-$PWD/GRUPO07}" # usa el primer parámetro o el directorio actual
CONFDIRINSTALL="./conf"

CONFDIR="$GRUPO/config"
CONFIGFILE="$CONFDIR/CIPAK.cnf"
CONFIGFILETEMP="$CONFDIRINSTALL/CIPAK.temp"

pathResult=""
BINDIR="$GRUPO/binarios"
MAEDIR="$GRUPO/maestros"
ARRIDIR="$GRUPO/arribados"
#$GRUPO/datos #con los archivos de la catedra
BACKUPDIR="$GRUPO/respaldo"
OKDIR="$GRUPO/aceptados"
PROCDIR="$GRUPO/procesados"
INFODIR="$GRUPO/informes"
LOGDIR="$GRUPO/bitacoras"
NOKDIR="$GRUPO/rechazados"
DATOSDIR="./mae"
DATASIZE=100 #100Mb  #DATASIZE=104857600 #100Mb
LOGEXT=".log"
LOGSIZE=400 #400Kb #LOGSIZE=409600 #400Kb
LOGCOMMAND="./bin/GrabarBitacora.sh"
VERSIONPERL=5

SLEEPTIME=1
#*************************** Funciones ***************************
function log() {
	command=$1
	message=$2
	type=$3
	if [ $# -ge 2 ] && [ $# -le 3 ]
	then
		$LOGCOMMAND "$command" "$message" "$type"
	fi
}

function initInstalation(){
	while [ -z $optSelect ]
	do
		clear
	#Verifico version de perl instalada
	log "Installer" "Verificando versión de perl instalada" "I"

	PERLVERSION=$(perl -v | grep 'v[0-9]\.[0-9]\+\.[0-9]*' -o) #obtengo la version de perl
	NUMPERLVERSION=$(echo $PERLVERSION | cut -d"." -f1 | sed 's/^v\([0-9]\)$/\1/') #obtengo el primer numero

	if [ -z "$NUMPERLVERSION" ] || [ $NUMPERLVERSION -lt $VERSIONPERL ]
	then
		echo "Para ejecutar el sistema CIPAK es necesario contar con Perl $VERSIONPERL o superior."
		echo "Efectúe su instalación e inténtelo nuevamente."
		echo "Proceso de Instalación Cancelado"
		log  "Installer" "Para ejecutar el sistema CIPAK es necesario contar con Perl $VERSIONPERL o superior." "E"
		log  "Installer"  "Efectúe su instalación e inténtelo nuevamente." "E"
		log  "Installer"  "Proceso de Instalación Cancelado" "E"
		exit 3;
	else
		echo ""
		echo "PERL Instalada, Version: $PERLVERSION"
		#echo "PERL Instalada, Version:" $(perl -v)
		echo ""
		log "Installer" "PERL instalado. Version:$PERLVERSION" "I"
	fi

		echo '
		*************************************************************
		*             Proceso de Instalación de "CIPAK"             *
		*   Tema K Copyright © Grupo 7 - Primer Cuatrimestre 2016   *
		*************************************************************
    A T E N C I O N: Al instalar UD. expresa aceptar los términos y condiciones
    del "ACUERDO DE LICENCIA DE SOFTWARE" incluido en este paquete.
    '

		read -p " Acepta?  Si – No: " optSelect
		optSelect=$(echo $optSelect | grep '^[Ss][Ii]$\|^[Nn][Oo]$' | tr '[:upper:]' '[:lower:]')
	done

	#si el usuario no acepta finalizo el script
	if [ $optSelect = "no" ]
	then
		log "Installer" "Usuario NO acepto ACUERDO DE LICENCIA DE SOFTWARE"
		exit 2
	fi

	#Usuario Acepto los terminos
	log "Installer" "Usuario acepto ACUERDO DE LICENCIA DE SOFTWARE" "I"

	echo "configuracion temporal"
	#Si existe vuelvo a generar el archivo de configuracion temporal
	if [ -a $CONFIGFILETEMP ]
	then
		log "Installer" "Genero archivo de configuracion temporal" "I"
		echo "Genero archivo de configuracion temporal"
		rm $CONFIGFILETEMP
		#touch $CONFIGFILETEMP
	fi

	echo "GRUPO=$GRUPO=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP

	echo "CONFDIR=$CONFDIR=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP
	echo "SLEEPTIME=$SLEEPTIME=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP

	getDirectoryPath "Defina el directorio de instalación de los ejecutables ($BINDIR):" "$BINDIR"
	BINDIR=$pathTemp
	echo "BINDIR=$pathTemp=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP

	getDirectoryPath "Defina directorio para maestros ($MAEDIR):" "$MAEDIR"
	MAEDIR=$pathTemp
	echo "MAEDIR=$pathTemp=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP

	getDirectoryPath "Defina el Directorio de recepción de los archivos de novedades ($ARRIDIR):" "$ARRIDIR"
	ARRIDIR=$pathTemp
	echo "ARRIDIR=$pathTemp=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP

	readNumber "Defina espacio mínimo libre para la recepción de archivos de novedades en Mbytes ($DATASIZE)" "$DATASIZE"
	DATASIZETEMP=$numberTemp
	DATASIZEDIR=$(df -B1024 "$ACTUALDIR" | tail -n1 | sed -e"s/\s\{1,\}/;/g" | cut -f4 -d';')
	DATASIZEDIR=$(echo "scale=0 ; $DATASIZEDIR/1024" | bc -l) #lo paso a Mb

	while [ $DATASIZEDIR -lt $DATASIZETEMP ]
	do
		echo "Insuficiente espacio en disco."
		echo "Espacio disponible: $DATASIZEDIR Mb."
		echo "Espacio requerido $DATASIZETEMP Mb"
		echo "Inténtelo nuevamente."
		echo ""
		readNumber "Defina espacio mínimo libre para la recepción de archivos de novedades en Mbytes ($DATASIZE)" "$DATASIZE"
		DATASIZETEMP=$numberTemp
	done
	DATASIZE=$DATASIZETEMP
	echo "DATASIZE=$DATASIZETEMP=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP

	getDirectoryPath "Defina el directorio de grabación de los archivos aceptados ($OKDIR):" "$OKDIR"
	OKDIR=$pathTemp
	echo "OKDIR=$pathTemp=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP

	#llamadas sospechosas -> PROCDIR
	getDirectoryPath "Defina el directorio de grabación de los registros ofertas procesadas ($PROCDIR):" "$PROCDIR"
	PROCDIR=$pathTemp
	echo "PROCDIR=$pathTemp=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP

	#Directorio de grabacion de los reportes
	getDirectoryPath "Defina el directorio de grabación los reportes ($INFODIR):" "$INFODIR"
	INFODIR=$pathTemp
	echo "INFODIR=$pathTemp=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP

	getDirectoryPath "Defina el directorio de logs ($LOGDIR):" "$LOGDIR"
	LOGDIR=$pathTemp
	echo "LOGDIR=$pathTemp=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP

	getExtension "Ingrese la extensión para los archivos de log ($LOGEXT): " "$LOGEXT"
	LOGEXT=$extDefault
	echo "LOGEXT=$extDefault=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP

	readNumber "Defina el tamaño máximo para los archivos $LOGEXT en Kbytes ($LOGSIZE)" "$LOGSIZE"
	LOGSIZETEMP=$numberTemp
	LOGSIZEDISP=$(df -B1024 "$ACTUALDIR" | tail -n1 | sed -e"s/\s\{1,\}/;/g" | cut -f4 -d';')

	while [ $LOGSIZEDISP -lt $LOGSIZETEMP ]
	do
		echo "Insuficiente espacio en disco."
		echo "Espacio disponible: $LOGSIZEDISP Kb."
		echo "Espacio requerido $LOGSIZETEMP Kb"
		echo "Cancele la instalación o inténtelo nuevamente."
		echo ""
		readNumber "Defina el tamaño máximo para los archivos $LOGEXT en Kbytes ($LOGSIZE)" "$LOGSIZE"
		LOGSIZETEMP=$numberTemp
	done
	LOGSIZE=$LOGSIZETEMP
	echo "LOGSIZE=$LOGSIZETEMP=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP

	getDirectoryPath "Defina el directorio de grabación los archivos rechazados ($NOKDIR):" "$NOKDIR"
	NOKDIR=$pathTemp
	echo "NOKDIR=$pathTemp=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP

	#Agrego directorio de Backup al archivo de configuracion
	echo "BACKUPDIR=$BACKUPDIR=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP

}

function getDirectoryPath(){
	# echo $1
	# echo $2
	msj=$1
	pathDefault=$2
	pathTemp=""

	while [ -z $pathTemp ]
	do
		read -p "$msj" pathTemp
		#echo "de nuevo: $pathTemp"
		if [ -z "$pathTemp" ]
		then
			pathTemp=$pathDefault
		else
			#pathTemp=$(echo $pathTemp | grep '^/.*$' )
			#Valido caracteres alfanumericos en path
			pathTemp=$(echo "$pathTemp" | grep '^/[a-zA-Z0-9]*$' )
			#valido que no se pueda seleccionar el directorio conf
			pathTemp=$(echo "$pathTemp" | grep -v '^/conf$' )
			if [ ! -z "$pathTemp" -a "$pathTemp" != " " ]
			then
				pathTemp=$GRUPO$pathTemp
			else
				echo 'Path invalido, ingrese nuevamente'
			fi
		fi
	done
}

function getExtension(){
	msj=$1
	extDefault=$2
	extTemp=""
	while [ -z $extTemp ]
		do
		read -p "$msj" extTemp
		if [ -z $extTemp ]
		then
			extDefault=$2
			extTemp=$2
		else
			extTemp=$(echo $extTemp | grep '^\..*$' )
			if [ ! -z "$extTemp" -a "$extTemp" != " " ]
			then
				extDefault=$extTemp
			fi
		fi
	done
}

function readNumber(){
	msj=$1
	numberDefault=$2
	numberTemp=""

	while [ -z $numberTemp ]
	do
		read -p "$msj: " result

		#Si pulso enter pongo el valor por defecto
		if [ -z $result ]
		then
			result=$numberDefault
		fi

		numberTemp=$(echo $result | grep '^[0-9]*$')
	done

	return $numberTemp
}

function executeInstaler(){
	STATUSINST=$1
	while [ -z $optIniciar ]
	do
		clear
		echo '
		*************************************************************
		*             Proceso de Instalación de "CIPAK"             *
		*   Tema K Copyright © Grupo 7 - Primer Cuatrimestre 2016   *
		*************************************************************
    '
    echo "
	Directorio de Configuracion: $CONFDIR
	Directorio de Ejecutables:   $BINDIR
	Directorio de  Maestros: $MAEDIR
	Directorio de recepción de archivos de novedades:  $ARRIDIR
	Espacio mínimo libre para arribos: $DATASIZE Mb
	Directorio de  archivos aceptados: $OKDIR
	Directorio de ofertas procesadas:  $PROCDIR
	Directorio de reportes: $INFODIR
	Directorio de Logs de Comandos: $LOGDIR/<comando>$LOGEXT
	Tamaño máximo para los archivos de log del sistema: $LOGSIZE Kb
	Directorio de archivos rechazados: $NOKDIR
	Estado de la instalación: $STATUSINST
		"

		read -p "Iniciando Instalación. Esta Ud. seguro? (Si - No): " optIniciar
		optIniciar=$(echo $optIniciar | grep '^[Ss][Ii]$\|^[Nn][Oo]$' | tr '[:upper:]' '[:lower:]')
	done

	#si el usuario no acepta finalizo el script
	if [ $optIniciar = "no" ]
	then
		clear
		log "Installer" "Usuario No Quiere realizar la instalacion"
		exit 4
	fi

	if [ -d "$GRUPO" ]
	then
		deletDirOpt=""
		while [ -z $deletDirOpt ]
		do
			read -p "Existen una instalación en el directorio $GRUPO, se borraran todos los datos para realizar la nueva instalacion, esta seguro? (Si - No): " deletDirOpt
			optSelect=$(echo $deletDirOpt | grep '^[Ss][Ii]$\|^[Nn][Oo]$' | tr '[:upper:]' '[:lower:]')
		done

		if [ $deletDirOpt = "no" ]
		then
			log "Installer" "El usuario no quiere eliminar el directorio $GRUPO existente" "I"
			exit 5
		else
			log "Installer" "Eliminando contenido de directorio $GRUPO" "I"
			rm -rf "$GRUPO"
		fi
	fi

	clear
	echo "Creando Estructuras de directorio. . . . "
	echo "$BINDIR"
	mkdir -p "$BINDIR"

	echo "$MAEDIR"
	mkdir -p "$MAEDIR"

	echo "$OKDIR"
	mkdir -p "$OKDIR"

	echo "$PROCDIR"
	mkdir -p "$PROCDIR"

	echo "$INFODIR"
	mkdir -p "$INFODIR"

	echo "$LOGDIR"
	mkdir -p "$LOGDIR"

	echo "$ARRIDIR"
	mkdir -p "$ARRIDIR"

	echo "$NOKDIR"
	mkdir -p "$NOKDIR"

	mkdir -p "$CONFDIR"

	#cp "MoverA.sh" "$BINDIR/MoverA.sh"
	#chmod +r+x "$BINDIR/MoverA.sh"

	#Mover los ejecutables y funciones al directorio BINDIR mostrando el siguiente mensaje
	echo "Instalando Programas y Funciones"
	#Muevo el script para mover archivos
	#for i in $(ls *.sh *.pl)
	for i in $(ls bin/*.sh)
	 do
		cp "$i" "$BINDIR/"
	done
	for i in $(ls bin/*.pl)
	 do
		cp "$i" "$BINDIR/"
	done

	for i in $(ls "$BINDIR")
	 do
		chmod u+x "$BINDIR/$i"
	done

	#Muevo la configuracion creada por el instalador.
	#for i in $(ls $CONFDIRINSTALL)
	#do
	#	cp "$CONFDIRINSTALL/$i" "$CONFDIR/$i"
	#done

	LOGCOMMAND="$BINDIR/GrabarBitacora.sh"

	#Mover los archivos maestros y tablas al directorio MAEDIR mostrando el siguiente mensaje
	echo "Instalando Archivos Maestros y Tablas"
	for i in $(ls $DATOSDIR/*)
	 do
		cp "$i" "$MAEDIR/"
	done

	#Actualizar el archivo de configuración mostrando el siguiente mensaje
	echo "Actualizando la configuración del sistema"
	log "Installer" "Actualizando la configuración del sistema" "I"

	log "Installer" "Convirtiendo $CONFDIR/  ->  $CONFIGFILE" "I"

	cp "$CONFIGFILETEMP" "$CONFIGFILE"

	#copiando log de instalacion a bitacoras.
	cp "$CONFDIRINSTALL/Installer.log" "$LOGDIR/Installer.log"

	echo "Instalación CONCLUIDA"
	log "Installer" "Instalación CONCLUIDA" "I"


	#Copio todo al directorio de respaldo
	mkdir -p $BACKUPDIR

	for i in $(ls bin)
	 do
		cp "bin/$i" "$BACKUPDIR/$i"
		#mv "$i" "$BACKUPDIR/$i"
	done


	#Elimino Archivos
	#rm -rf ./Datos
	rm -rf $CONFDIRINSTALL
	#rm *.sh
	#rm *.pl
	#rm *.md
}


#Si no existe la carpeta de configuracion la creo.
if [ ! -d $CONFDIRINSTALL ]
	then
	mkdir -p $CONFDIRINSTALL
fi

#Otorgo permisos a los comando que voy a utilizar
chmod u+r+x $LOGCOMMAND

#Inicio del instalador
log "Installer" "Inicio de Ejecución de Installer"

echo "Log de la instalación: $CONFDIRINSTALL/$LOGFILEINS"
log "Installer" "Log de la instalación: $CONFDIRINSTALL/$LOGFILEINS"

echo "Directorio predefinido de configuración: $CONFDIR"
log "Installer" "Directorio predefinido de configuración: $CONFDIR"

#Detecto si hay una instalacion previa
if [ -a $CONFIGFILETEMP ]
then
	#Hay una instalación previa
	log "Installer" "Hay una instalación" "I"

	BASEDIRTMP=$(grep '^GRUPO' $CONFIGFILETEMP | awk -F"=" '{print $2}')
	CONFIGDIRTMP=$(grep '^CONFDIR' $CONFIGFILETEMP | awk -F"=" '{print $2}')
	SLEEPTIMETMP=$(grep '^SLEEPTIME' $CONFIGFILETEMP | awk -F"=" '{print $2}')
	BINDIRTMP=$(grep '^BINDIR' $CONFIGFILETEMP | awk -F"=" '{print $2}' )
	MAEDIRTMP=$(grep '^MAEDIR' $CONFIGFILETEMP | awk -F"=" '{print $2}' )
	ARRIDIRTMP=$(grep '^ARRIDIR' $CONFIGFILETEMP | awk -F"=" '{print $2}' )
	DATASIZETMP=$(grep '^DATASIZE' $CONFIGFILETEMP | awk -F"=" '{print $2}' )
	OKDIRTMP=$(grep '^OKDIR' $CONFIGFILETEMP | awk -F"=" '{print $2}' )
	PROCDIRTMP=$(grep '^PROCDIR' $CONFIGFILETEMP | awk -F"=" '{print $2}' )
	INFODIRTMP=$(grep '^INFODIR' $CONFIGFILETEMP | awk -F"=" '{print $2}' )
	LOGDIRTMP=$(grep '^LOGDIR' $CONFIGFILETEMP | awk -F"=" '{print $2}' )
	LOGEXTTMP=$(grep '^LOGEXT' $CONFIGFILETEMP | awk -F"=" '{print $2}' )
	LOGSIZETMP=$(grep '^LOGSIZE' $CONFIGFILETEMP | awk -F"=" '{print $2}' )
	NOKDIRTMP=$(grep '^NOKDIR' $CONFIGFILETEMP | awk -F"=" '{print $2}' )
	BACKUPDIRTMP=$(grep '^BACKUPDIR' $CONFIGFILETEMP | awk -F"=" '{print $2}' )

	declare -a VAR_FALTANTES; #Array con los directorios que falta configurar
	declare -a VAR_COMPLETO; #Array con los directorios que falta configurar

	if [ -z $BASEDIRTMP ]
	then
		echo "GRUPO=$GRUPO=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP
	fi

	if [ -z $CONFIGDIRTMP ]
	then
		echo "CONFDIR=$CONFDIR=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP
	fi

	if [ -z $SLEEPTIMETMP ]
	then
		echo "SLEEPTIME=$SLEEPTIME=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP
	fi

	if [ -z $BINDIRTMP ]
	then
		VAR_FALTANTES=( ${VAR_FALTANTES[*]} BINDIR)
	else
		BINDIR=$BINDIRTMP
		VAR_COMPLETO=( ${VAR_COMPLETO[*]} BINDIR)
	fi

	if [ -z $MAEDIRTMP ]
	then
		VAR_FALTANTES=( ${VAR_FALTANTES[*]} MAEDIR)
	else
		MAEDIR=$MAEDIRTMP
		VAR_COMPLETO=( ${VAR_COMPLETO[*]} MAEDIR)
	fi

	if [ -z $ARRIDIRTMP ]
	then
		VAR_FALTANTES=( ${VAR_FALTANTES[*]} ARRIDIR)
	else
		ARRIDIR=$ARRIDIRTMP
		VAR_COMPLETO=( ${VAR_COMPLETO[*]} ARRIDIR)
	fi

	if [ -z $DATASIZETMP ]
	then
		VAR_FALTANTES=( ${VAR_FALTANTES[*]} DATASIZE)
	else
		DATASIZE=$DATASIZETMP
		VAR_COMPLETO=( ${VAR_COMPLETO[*]} DATASIZE)
	fi

	if [ -z $OKDIRTMP ]
	then
		VAR_FALTANTES=( ${VAR_FALTANTES[*]} OKDIR)
	else
		OKDIR=$OKDIRTMP
		VAR_COMPLETO=( ${VAR_COMPLETO[*]} OKDIR)
	fi

	if [ -z $PROCDIRTMP ]
	then
		VAR_FALTANTES=( ${VAR_FALTANTES[*]} PROCDIR)
	else
		PROCDIR=$PROCDIRTMP
		VAR_COMPLETO=( ${VAR_COMPLETO[*]} PROCDIR)
	fi

	if [ -z $INFODIRTMP ]
	then
		VAR_FALTANTES=( ${VAR_FALTANTES[*]} INFODIR)
	else
		INFODIR=$INFODIRTMP
		VAR_COMPLETO=( ${VAR_COMPLETO[*]} INFODIR)
	fi

	if [ -z $LOGDIRTMP ]
	then
		VAR_FALTANTES=( ${VAR_FALTANTES[*]} LOGDIR)
	else
		LOGDIR=$LOGDIRTMP
		VAR_COMPLETO=( ${VAR_COMPLETO[*]} LOGDIR)
	fi

	if [ -z $LOGEXTTMP ]
	then
		VAR_FALTANTES=( ${VAR_FALTANTES[*]} LOGEXT)
	else
		LOGEXT=$LOGEXTTMP
		VAR_COMPLETO=( ${VAR_COMPLETO[*]} LOGEXT)
	fi

	if [ -z $LOGSIZETMP ]
	then
		VAR_FALTANTES=( ${VAR_FALTANTES[*]} LOGSIZE)
	else
		LOGSIZE=$LOGSIZETMP
		VAR_COMPLETO=( ${VAR_COMPLETO[*]} LOGSIZE)
	fi

	if [ -z $NOKDIRTMP ]
	then
		VAR_FALTANTES=( ${VAR_FALTANTES[*]} NOKDIR)
	else
		NOKDIR=$NOKDIRTMP
		VAR_COMPLETO=( ${VAR_COMPLETO[*]} NOKDIR)
	fi



	if [ ${#VAR_FALTANTES[@]} -eq 0 ] #No falta ninguna variable en el archivo temporal
	then
		initInstalation
	else
	echo "Direct. de Configuracion: $CONFDIR"

	for VARVALUE in "${VAR_COMPLETO[@]}"; do
		case $VARVALUE in
			BINDIR )
				echo "Directorio Ejecutables:   $BINDIR";;
			MAEDIR )
				echo "Directorio de Maestros: $MAEDIR";;
			ARRIDIR )
				echo "Directorio de recepción de archivos de novedades:  $ARRIDIR";;
			DATASIZE )
				echo "Espacio mínimo libre para las novedades: $DATASIZE Mb";;
			OKDIR )
				echo "Directorio de archivos aceptados: $OKDIR";;
			PROCDIR )
				echo "Directorio de archivos de ofertas procesadas:  $PROCDIR";;
			INFODIR )
				echo "Directorio de Archivos de reportes: $INFODIR";;
			LOGDIR )
				echo "Directorio de Logs de Comandos: $LOGDIR/<comando>$LOGEXT";;
			#LOGEXT )
				#echo "LOGEXT: $LOGEXT";;
			LOGSIZE )
				echo "Tamaño máximo para los archivos de log del sistema: $LOGSIZE Kb";;
			NOKDIR )
				echo "Directorio de Archivos rechazados: $NOKDIR";;
			esac
	done

	echo ""
	echo "Componentes Faltantes: "
	for VARVALUE in "${VAR_FALTANTES[@]}"
	do
		case $VARVALUE in
			BINDIR )
				echo "Directorio Ejecutables";;
			MAEDIR )
				echo "Directorio de Maestros";;
			ARRIDIR )
				echo "Directorio de recepción de archivos de novedades";;
			DATASIZE )
				echo "Espacio mínimo libre para novedades";;
			OKDIR )
				echo "Directorio de archivos aceptados";;
			PROCDIR )
				echo "Directorio de llamdas sospechosas";;
			INFODIR )
				echo "Directorio de Archivos de reportes";;
			LOGDIR )
				echo "Directorio de Logs de Comandos";;
			#LOGEXT )
				#echo "LOGEXT: $LOGEXT";;
			LOGSIZE )
				echo "Tamaño máximo para los archivos de log del sistema";;
			NOKDIR )
				echo "Directorio de Archivos rechazados";;
			esac
	done
	echo ""
	echo "Estado de la instalación: INCOMPLETA"

	while [ -z $optSelect ]
	do
		read -p " Desea completar la instalación? (Si - No): " optSelect
		optSelect=$(echo $optSelect | grep '^[Ss][Ii]$\|^[Nn][Oo]$' | tr '[:upper:]' '[:lower:]')
	done
		if [ $optSelect = "no" ]
	then
		log "Installer" "Usuario no quiere continuar con la instalación" "I"
		exit 6
	fi

	for VARVALUE in "${VAR_FALTANTES[@]}"; do
		case $VARVALUE in
			BINDIR )
				getDirectoryPath "Defina el directorio de instalación de los ejecutables ($BINDIR):" "$BINDIR"
				BINDIR=$pathTemp
				echo "BINDIR=$pathTemp=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP;;
			MAEDIR )
				getDirectoryPath "Defina directorio para maestros ($MAEDIR):" "$MAEDIR"
				MAEDIR=$pathTemp
				echo "MAEDIR=$pathTemp=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP;;
			ARRIDIR )
				getDirectoryPath "Defina el Directorio de recepción de archivos de novedades ($ARRIDIR):" "$ARRIDIR"
				ARRIDIR=$pathTemp
				echo "ARRIDIR=$pathTemp=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP;;
			DATASIZE )
				readNumber "Defina espacio mínimo libre para el arribo de archivos de novedades en Mbytes ($DATASIZE)" "$DATASIZE"
				DATASIZETEMP=$numberTemp
				DATASIZEDIR=$(df -B1024 "$ACTUALDIR" | tail -n1 | sed -e"s/\s\{1,\}/;/g" | cut -f4 -d';')
				DATASIZEDIR=$(echo "scale=0 ; $DATASIZEDIR/1024" | bc -l) #lo paso a Mb

				while [ $DATASIZEDIR -lt $DATASIZETEMP ]
				do
					echo "Insuficiente espacio en disco."
					echo "Espacio disponible: $DATASIZEDIR Mb."
					echo "Espacio requerido $DATASIZETEMP Mb"
					echo "Inténtelo nuevamente."
					echo ""
					readNumber "Defina espacio mínimo libre para el arribo de archivos de novedades en Mbytes ($DATASIZE)" "$DATASIZE"
					DATASIZETEMP=$numberTemp
				done
				DATASIZE=$DATASIZETEMP
				echo "DATASIZE=$DATASIZETEMP=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP;;
			OKDIR )
				getDirectoryPath "Defina el directorio de grabación de los archivos aceptados ($OKDIR):" "$OKDIR"
				OKDIR=$pathTemp
				echo "OKDIR=$pathTemp=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP;;
			PROCDIR )
				getDirectoryPath "Defina el directorio de grabación de los registros de las ofertas procesadas ($PROCDIR):" "$PROCDIR"
				PROCDIR=$pathTemp
				echo "PROCDIR=$pathTemp=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP;;
			INFODIR )
				getDirectoryPath "Defina el directorio de grabación de los reportes ($INFODIR):" "$INFODIR"
				INFODIR=$pathTemp
				echo "INFODIR=$pathTemp=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP;;
			LOGDIR )
				getDirectoryPath "Defina el directorio de logs ($LOGDIR):" "$LOGDIR"
				LOGDIR=$pathTemp
				echo "LOGDIR=$pathTemp=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP;;
			LOGEXT )
				getExtension "Ingrese la extensión para los archivos de log ($LOGEXT): " "$LOGEXT"
				LOGEXT=$extDefault
				echo "LOGEXT=$extDefault=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP;;
			LOGSIZE )
				readNumber "Defina el tamaño máximo para los archivos $LOGEXT en Kbytes ($LOGSIZE)" "$LOGSIZE"
				LOGSIZETEMP=$numberTemp
				LOGSIZEDISP=$(df -B1024 "$ACTUALDIR" | tail -n1 | sed -e"s/\s\{1,\}/;/g" | cut -f4 -d';')
				#LOGSIZEDISP=$(echo "scale=0 ; $LOGSIZEDISP/1024" | bc -l) #lo paso a Mb

				while [ $LOGSIZEDISP -lt $LOGSIZETEMP ]
				do
					echo "Insuficiente espacio en disco."
					echo "Espacio disponible: $LOGSIZEDISP Kb."
					echo "Espacio requerido $LOGSIZETEMP Kb"
					echo "Inténtelo nuevamente."
					echo ""
					readNumber "Defina el tamaño máximo para los archivos $LOGEXT en Kbytes ($LOGSIZE)" "$LOGSIZE"
					LOGSIZETEMP=$numberTemp
				done
				LOGSIZE=$LOGSIZETEMP
				echo "LOGSIZE=$LOGSIZETEMP=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP;;
			NOKDIR )
				getDirectoryPath "Defina el directorio de grabación de los reportes ($NOKDIR):" "$NOKDIR"
				NOKDIR=$pathTemp
				echo "NOKDIR=$pathTemp=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP;;
		esac
	done
	fi

	if [ -z $BACKUPDIRTMP ]
	then
		echo "BACKUPDIR=$BACKUPDIR=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP
	fi
	executeInstaler "LISTA"

else
	#NO Hay una instalación previa
	log "Installer" "No hay instalación, mostrando aceptación de terminos y condiciones" "I"

	initInstalation

	executeInstaler "LISTA"
exit 0;
fi
