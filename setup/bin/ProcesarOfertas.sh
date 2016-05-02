#!/bin/bash

source MoverArchivo.sh

#Variables de entorno provisorias
MAEDIR="../maestros"
OKDIR="../aceptados"
PROCDIR="../procesados"

SUSCRIPTORES="$MAEDIR/temaK_padron.csv.xls"
FECHAS_ADJUDICACION="$MAEDIR/FechasAdj.csv.xls"
GRUPOS="$MAEDIR/grupos.csv.xls"
ACEPTADOS="$PROCDIR/validas"
RECHAZADOS="$PROCDIR/rechazadas"
PROCESADOS="$PROCDIR/procesados"

# Creo los directorios si no existen
mkdir -p $ACEPTADOS
mkdir -p $RECHAZADOS
mkdir -p $PROCESADOS


function calcularFechaUltimoActo()
{
	fechaUltActo="19900101" # Seteo una fecha para calcular luego
	IFS="
	" #Determina el internal field separator

	while read -r fch
	do
		# Verifica que sea una fecha valida
		if date -d "${fch:6:4}${fch:3:2}${fch:0:2}" &> /dev/null
		then
			# Verifica que la fecha sea menor a la fecha actual
			if (( ($(date -d "${fch:6:4}${fch:3:2}${fch:0:2}" +%s) < $(date +%s)) ))
			then
				# Verifica que la fecha guardada anteriormente no sea posterior a esta
				if (( ($(date -d "${fch:6:4}${fch:3:2}${fch:0:2}" +%s) > $(date -d "$fechaUltActo" +%s)) ))
				then
					fechaUltActo="${fch:6:4}${fch:3:2}${fch:0:2}"
				fi
			fi
		fi
	done < $FECHAS_ADJUDICACION
}

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

function importeValido()
{
	# Validar importe. Mayor o igual al monto mínimo (valor de cuota pura * cantidad de cuotas para licitación)
	# y menor o igual al monto máximo (valor de cuota pura * cantidad de cuotas pendientes)

	ofertaSuscriptor=`echo $2 | cut -f 2 -d";" | sed s/","/"."/`
	cuotaPura=`echo $1 | cut -f 4 -d";" | sed s/","/"."/`
	cantidadCuotasLicitacion=`echo $1 | cut -f 6 -d";"`
	cantidadCuotasPendientes=`echo $1 | cut -f 5 -d";"`

	montoMinimo=`echo - | awk "{print $cuotaPura * $cantidadCuotasLicitacion}"`
	montoMaximo=`echo - | awk "{print $cuotaPura * $cantidadCuotasPendientes}"`
	if [[ `echo - | awk "{print $montoMinimo<=$ofertaSuscriptor}"` = 1 ]] 
	then
		if [[ `echo - | awk "{print $ofertaSuscriptor<=$montoMaximo}"` = 1 ]]
		then
			return 0
		else msg="SUPERA EL MONTO MAXIMO";
		fi
	else msg="NO ALCANZA EL MONTO MINIMO";
	fi
	return 1 # Oferta invalida
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

					if importeValido `grep ${suscriptor:0:4} $GRUPOS` $1
					then
						msg="OFERTA VALIDA"
						return 0
					fi

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

function grabarOfertaInvalida()
{
	local oferta=$1
	local archivo=$2

	auxConcesionario=${archivo:0:4} # Concesionario
	auxFechaActual="$(date +%d)/$(date +%m)/$(date +%Y)" # Fecha
	registroOferta="$archivo;$msg;${oferta:0:-1};$USER;$auxFechaActual"
	echo $registroOferta >> $RECHAZADOS/$auxConcesionario
}

function grabarOfertaValida()
{
	local oferta=$1
	local archivo=$2

	auxConcesionario=${archivo:0:4} # Concesionario
	auxFechaArchivo=${archivo:5:8} # Fecha archivo
	auxGrupo=${oferta:0:4} # Grupo
	auxNroOrden=${oferta:4:3} # Nro de orden
	auxContrato=${oferta:0:7} # Contrato fusionado
	auxImporteOfertado=`echo $oferta | cut -f 2 -d";" | sed s/'\n'/""/` # Importe Ofertado
	auxNombre=`grep --text "^${oferta:0:4};${oferta:4:3}" $SUSCRIPTORES | cut -f 3 -d";"` # Nombre del suscriptor
	auxUser=$USER # Usuario
	auxFechaActual="$(date +%d)/$(date +%m)/$(date +%Y)" # Fecha
	registroOferta="$auxConcesionario;$auxFechaArchivo;$auxContrato;$auxGrupo;$auxNroOrden;${auxImporteOfertado:0:-1};$auxNombre;$auxUser;$auxFechaActual"
	echo $registroOferta >> $ACEPTADOS/$fechaUltActo
}

#--------------------------------------------------------------------------------------------------------#

cantidadOfertasValidas=0
cantidadOfertasRechazadas=0
cantidadArchivosOfertas=`ls -1 $OKDIR | wc -w` # Calcula cantidad de archivos a procesar

./GrabarBitacora.sh "ProcesarOfertas" "Inicio de ProcesarOfertas" "INFO"
./GrabarBitacora.sh "ProcesarOfertas" "Cantidad de archivos a procesar: $cantidadArchivosOfertas" "INFO"

calcularFechaUltimoActo
archivoOfertaAceptado=false
msg1=""

listaArchivos=`ls -1 $OKDIR | sort -t _ -k2` # Ordeno los archivos cronologicamente
for archivo in $listaArchivos
do
	# Proceso los archivos

	# 2.1 Verificar que no sea un archivo duplicado
	if [ ! `existeDuplicado $archivo` ]
	then
		# 2.2 Verificar los campos del primer registro
		if formatoCamposValido $archivo
		then
			# 3 Luego de verificado lo anterior grabar en el log archivo a procesar
			./GrabarBitacora.sh "ProcesarOfertas" "Archivo a procesar: $archivo" "INFO"
			archivoOfertaAceptado=true
			msg1="El archivo $archivo fue aceptado"

			# 4 Validar oferta
			for oferta in `more "$OKDIR/$archivo"`
			do
				if ofertaValida $oferta
				then
					# 5 Grabar oferta valida en el registro de ofertas validas
					grabarOfertaValida $oferta $archivo
					let cantidadOfertasValidas++
				else
					# 6 Rechazar oferta, en el caso que alguna de las validaciones sea invalida,
					# grabando en el registro de ofertas rechazadas
					grabarOfertaInvalida $oferta $archivo
					let cantidadOfertasRechazadas++
				fi
			done
			let total=cantidadOfertasValidas+cantidadOfertasRechazadas
			./GrabarBitacora.sh "ProcesarOfertas" "Registros leidos = $total; Ofertas validas = $cantidadOfertasValidas - Ofertas rechazadas = $cantidadOfertasRechazadas " "INFO"
		else
			archivoOfertaAceptado=false
			msg1="Se  rechaza  el  archivo $archivo  porque  su  estructura  no  se  corresponde  con  el formato esperado"
		fi
	else
		archivoOfertaAceptado=false
		msg1="Se rechaza el archivo $archivo por estar DUPLICADO"
	fi
	cantidadOfertasValidas=0
	cantidadOfertasRechazadas=0

	# Muevo los archivos al directorio correspondiente y guardo el suceso en la bitacora
	if ( ! $archivoOfertaAceptado )
	then
		MoverArchivos "$OKDIR/$archivo" "$NOKDIR/$archivo" "ProcesarOfertas"
		./GrabarBitacora.sh "ProcesarOfertas" "$msg1" "WAR"
	else
		MoverArchivos "$OKDIR/$archivo" "$PROCESADOS/$archivo" "ProcesarOfertas"
		./GrabarBitacora.sh "ProcesarOfertas" "$msg1" "INFO"
	fi
	archivoOfertaAceptado=false
	msg1=""
done
./GrabarBitacora.sh "ProcesarOfertas" "Fin de ProcesarOfertas" "INFO"
PROCESARENEJECUCION=false