OLDIFS=$IFS
IFS=";"

#Variables locales
id_cont=1
underscore="_"
cont=1
archivos=()

#Variables de entorno
dir_mae=$MAEDIR
dir_log=$LOGDIR
dir_proc=$PROCDIR

#Grabar en el log a traves de GrabarBitacora el inicio del sorteo

#Lectura del archivo de entrada y creo archivos de salida
while read fecha razon
do
    #Armo el nombre del archivo
    nombre_arch="$id_cont$underscore$fecha"
    #Reemplazo la barra por un guion
    nombre_salida=$(echo $nombre_arch | sed 's|/|-|g')

    id_cont=$[$id_cont +1]

    #Creo el archivo
    touch "$dir_proc/$nombre_salida"

    #Guardo en el array el nombre del archivo
    archivos+=($nombre_salida)
done < "$dir_mae/$1"
IFS=$OLDIFS

#Escritura de las salidas de los sorteos
for i in ${archivos[@]}
do
echo $i
    #Inicializo en counter en 1 para la iteracion del archivo actual
    cont=1
    #Armo un array con los numeros random del 1 a 168 inclusive
    numeros=$(shuf -e $(seq 1 168))

    #Escribo en el archivo de salida
    for o in ${numeros[@]}
    do
        echo "$cont;$o" >> "$dir_proc/$i"
        cont=$[$cont +1]
    done
done

#Grabar en el log a traves de GrabarBitacora el cierre del sorteo                                                                                                                                                                                                        55,66       Final
