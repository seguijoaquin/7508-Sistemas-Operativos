#!/bin/bash
# Esta funcion tiene por objeto centralizar el movimiento de archivos 
# que deben realizar la mayor parte de los comandos de este sistema 

# Ejemplo de llamado: MoverArchivos "/origen/example.csv" "/destino/example.csv" MyProcess

#Return values
#1: parametro origen sin contenido
#2: parametro destino sin contenido
#3: direccion de origen coincide con destino
#4: diereccion de origen no existe
#5: diereccion de destino no existe

#verifica si esta definida la variable global con el numero de secuencia de archivos duplicados
if [ -z "$sec_duplicados" ]
then
	sec_duplicados=0
fi

#source Log.sh

function MoverArchivos {
	origen=$1
	destino=$2
	dir_destino=${destino%/*}
	filename_destino=${destino##*/}
	comando_inv=$3

	#validacion origen no es vacio
	if [[ "$origen" == "" ]]
	then
		GrabarBitacora $comando_inv "MoverArchivos: Parametro origen vacio." ERROR
		return 1
	fi

	#validacion destino no es vacio
	if [[ "$destino" == "" ]]
	then
		GrabarBitacora $comando_inv "MoverArchivos: Parametro destino vacio." ERROR
		return 2
	fi

	#valido si el origen y destino son iguales
	if [[ "$origen" == "$destino" ]]
	then
		GrabarBitacora $comando_inv "MoverArchivos: Direccion de origen coincide con la de destino." ERROR
		return 3
	fi

	#valido si el archivo de origen existe
	if [ ! -e "$origen" ]
	then
		GrabarBitacora $comando_inv "MoverArchivos: Archivo de origen no existe." ERROR
		return 4
	fi

	#valido si existe el directorio destino
	if [ ! -e "$dir_destino" ]
	then
		GrabarBitacora $comando_inv "MoverArchivos: Direccion de destino no existe." ERROR
		return 5
	fi

	#valido si ya existe el file en destino
	if [ ! -e "$destino" ]
	then
		mv "$origen" "$destino"
		GrabarBitacora $comando_inv "MoverArchivos: El archivo fue movido. Origen: \"$origen\". Destino: \"$destino\"."
	else
		mkdir -p "${dir_destino}/dpl"
		if [ ! -e "${dir_destino}/dpl/${filename_destino}" ]
		then
			mv "$origen" "${dir_destino}/dpl/${filename_destino}"
			GrabarBitacora $comando_inv "MoverArchivos: El archivo ya existe en destino, se almacena como duplicado. Origen: \"$origen\". Destino: \"$destino\"."
		else
			sec_duplicados=`expr $sec_duplicados + 1`
			mv "$origen" "${dir_destino}/dpl/${filename_destino}.${contador}"
			GrabarBitacora $comando_inv "MoverArchivos: El archivo ya existe en destino y como duplicado, se renombra. Origen: \"$origen\". Destino: \"$destino\"."
		fi
	
	fi
}  
