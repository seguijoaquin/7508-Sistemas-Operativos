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

function formatoContratoValido()
{
	contratoConFormatoValido=`echo $1 | grep "^[0-9]\{7\};"`
	if [[ ! -z $contratoConFormatoValido ]]
	then # Posee formato valido
		return 0
	fi
	# Posee formato invalido
	return 1
}

function ofertaValida()
{
	msg=""
	if formatoContratoValido $1
	then # Verifica que el formato del contrato fusionado sea correcto

		suscriptor=`grep --text "^${1:0:4};${1:4:3}" $SUSCRIPTORES`
		if [[ ! -z $suscriptor ]]
		then # Valida el suscriptor contra el padrón de suscriptores.

			grupoAbierto=`grep ${suscriptor:0:4} $GRUPOS | grep "ABIERTO"`
			grupoNuevo=`grep ${suscriptor:0:4} $GRUPOS | grep "NUEVO"`

			if [[ ! -z $grupoAbierto ]] || [[ ! -z $grupoNuevo ]]
			then # Valida que el grupo este ABIERTO o NUEVO

				participa=`echo $suscriptor | cut -f 6 -d";"`

				if [[ $participa = "1" ]] || [[ $participa = "2" ]]
				then # Valida que el suscriptor participe

					#TODO: Validar importe. Mayor o igual al monto mínimo (valor de cuota pura * cantidad de cuotas para licitación)
					#TODO: Validar importe. Menor o igual al monto máximo (valor de cuota pura * cantidad de cuotas pendientes)

					return 0

				else msg="EL SUSCRIPTOR NO PARTICIPA";
				fi

			else msg="GRUPO CERRADO";
			fi

		else msg="SUSCRIPTOR NO EXISTENTE";
		fi

	else msg="FORMATO DE REGISTROS NO VALIDO";
	fi

	return 1
}

#--------------------------------------------------------------------------------------------------------#

cantidadOfertasValidas=0
cantidadOfertasRechazadas=0
cantidadArchivosOfertas=`ls -1 $OKDIR | wc -w` # Calcula cantidad de archivos a procesar

./GrabarBitacora.sh "ProcesarOfertas" "Inicio de ProcesarOfertas" "INFO"
./GrabarBitacora.sh "ProcesarOfertas" "Cantidad de archivos a procesar: $cantidadArchivosOfertas" "INFO"

listaArchivos=`ls -1 $OKDIR | sort -t _ -k2` # Ordeno los archivos cronologicamente
for archivo in $listaArchivos
do
	#Proceso los archivos

	# 2.1 Verificar que no sea un archivo duplicado
	if [ ! `existeDuplicado $archivo` ]
	then
		# 2.2 Verificar los campos del primer registro
		if formatoCamposValido $archivo
		then
			# 3 Luego de verificado lo anterior grabar en el log archivo a procesar
			./GrabarBitacora.sh "ProcesarOfertas" "Archivo a procesar: $archivo" "INFO"

			# 4 Validar oferta
			for oferta in `more "$OKDIR/$archivo"`
			do
				if ofertaValida $oferta
				then
					# 5 Grabar oferta valida en el registro de ofertas validas
					#TODO: Grabar oferta valida en el registro de ofertas validas
					let cantidadOfertasValidas++
				else
					# 6 Rechazar oferta, en el caso que alguna de las validaciones sea invalida,
					# grabando en el registro de ofertas rechazadas
					#TODO: Grabar oferta rechazada.
					let cantidadOfertasRechazadas++
				fi
			done
			let total=cantidadOfertasValidas+cantidadOfertasRechazadas
			./GrabarBitacora.sh "ProcesarOfertas" "Registros leidos = $total; Ofertas validas = $cantidadOfertasValidas - Ofertas rechazadas = $cantidadOfertasRechazadas " "INFO"
		else
			#TODO: Rechazar archivo por formato de primer registro invalido, con el mensaje “Se  rechaza  el  archivo  porque  su  estructura  no  se  corresponde  con  el formato esperado“
			echo “Se  rechaza  el  archivo  porque  su  estructura  no  se  corresponde  con  el formato esperado“
		fi
	else
		#TODO: Rechazar archivo con el mensaje “Se rechaza el archivo por estar DUPLICADO“
		echo “Se rechaza el archivo por estar DUPLICADO“
	fi
	cantidadOfertasValidas=0
	cantidadOfertasRechazadas=0
done

