#!/bin/bash

#Variables de entorno provisorias
MAEDIR="."
OKDIR="./Aceptados"
PROCDIR="./Procesados"


SUSCRIPTORES="$MAEDIR/temaK_padron.csv.xls"
FECHAS_ADJUDICACION="$MAEDIR/FechasAdj.csv.xls"
GRUPOS="$MAEDIR/grupos.csv.xls"
ACEPTADOS="$PROCDIR/Aceptados"
RECHAZADOS="$PROCDIR/Rechazados"
PROCESADOS="$PROCDIR/Procesados"


function existeDuplicado()
{
	archivoDuplicado=`ls -1 $PROCESADOS | grep "$1"`
	if [[ ! -z $archivoDuplicado ]]
	then # El archivo esta duplicado
		return 0
	fi # El archivo NO esta duplicado
	return 1
}

function formatoCamposValido()
{
	nroCamposPrimerRegistro=`head -1 "$OKDIR/$1" | sed s/";"/" "/ | wc -w`

	if [ $nroCamposPrimerRegistro -eq 2 ]
	then # Posee formato valido
		return 0
	fi
	# Posee formato invalido
	return 1
}

function ofertaValida()
{
	#TODO: Implementar
	return 0
}

#--------------------------------------------------------------------------------------------------------#

cantidadArchivosOfertas=`ls -1 $OKDIR | wc -w` # Calcula cantidad de archivos a procesar

./GrabarBitacora.sh "ProcesarOfertas" "Inicio de ProcesarOfertas" "INFO"
./GrabarBitacora.sh "ProcesarOfertas" "Cantidad de archivos a procesar: $cantidadArchivosOfertas" "INFO"

listaArchivos=`ls -1 $OKDIR | sort -t _ -k2` # Ordeno los archivos cronologicamente
for archivo in $listaArchivos
do
	#Proceso los archivos
	
	#echo "Proceso archivo $archivo"

	# 2.1 Verificar que no sea un archivo duplicado
	if [ ! `existeDuplicado $archivo` ]
	then
		# 2.2 Verificar los campos del primer registro
		if formatoCamposValido $archivo
		then
			# 3 Luego de verificado lo anterior grabar en el log archivo a procesar
			./GrabarBitacora.sh "ProcesarOfertas" "Archivo a procesar: $archivo" "INFO"

			# 4 Validar oferta
			for oferta in `more "$OKDIR/lear$archivo"`
			do
				if ofertaValida $oferta
				then
					# 5 Grabar oferta valida en el registro de ofertas validas
					echo "grabo oferta"
				else
					# 6 Rechazar oferta, en el caso que alguna de las validaciones sea invalida,
					# grabando en el registro de ofertas rechazadas
					echo "rechazo oferta"
				fi
			done
		else
			#TODO: Rechazar archivo por formato de primer registro invalido, con el mensaje “Se  rechaza  el  archivo  porque  su  estructura  no  se  corresponde  con  el formato esperado“
			echo “Se  rechaza  el  archivo  porque  su  estructura  no  se  corresponde  con  el formato esperado“
		fi
	else
		#TODO: Rechazar archivo con el mensaje “Se rechaza el archivo por estar DUPLICADO“
		echo “Se rechaza el archivo por estar DUPLICADO“
	fi
done

