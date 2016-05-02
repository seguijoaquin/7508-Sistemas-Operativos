#!/bin/bash

#Variables locales
id_cont=1
underscore="_"
cont=1
archivos=()

#Variables de entorno temporales hasta que haya script de seteo de variables de entorno
#MAEDIR="MaestrosyTablas_TemaK"
#PROCDIR="procesados"

fechas_adj="$MAEDIR/FechasAdj.mae" # TODO chequear con los docentes ya que el enunciado dice "fechas_adj.csv"
dir_sorteos="$PROCDIR/sorteos/"

#Genero el directorio de sorteos en caso de no existir
mkdir -p "$dir_sorteos"
#Lectura del archivo CSV de fechas de adjudicación y creación archivos de salida
while IFS=";" read fecha razon
do
    #Armo el nombre del archivo
    nombre_arch="$id_cont$underscore$fecha"
    #Reemplazo la barra por un guion
    nombre_salida=$(echo $nombre_arch | sed 's|/|-|g')
    archivo="$dir_sorteos/$nombre_salida"

    #Guardo en el array el nombre del archivo
    archivos+=($archivo)

    id_cont=$[$id_cont +1]
done < $fechas_adj

./GrabarBitacora.sh "GenerarSorteo" "Inicio de Sorteo" "INFO"
for archivo in "${archivos[@]}"
do
    #Creo el archivo
    touch $archivo
    echo "$archivo"
    #Inicializo el counter en 1 para la iteracion del archivo actual
    cont=1
    #Armo un array con los numeros random del 1 a 168 inclusive
    numeros=$(shuf -i 1-168)

    #Escribo en el archivo de salida
    for o in ${numeros[@]}
    do
        echo "$cont;$o" >> $archivo
        cont=$[$cont +1]
    done
done
./GrabarBitacora.sh "GenerarSorteo" "Fin de Sorteo" "INFO"
