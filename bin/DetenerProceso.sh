#!/bin/bash

cantParam=$#
hayFuncion=0

function pause() {
	read -p "$*"
}

#Chequeo ambiente
if [ "$BINDIR" != "" ]
then

	#Chequeo cantidad de parametros
	if [ "$cantParam" -eq 0 ] || [ "$cantParam" -eq 2 ] || [ "$cantParam" -eq 4 ]
	then
		#Chequeo / en BINDIR
		chequeo=$(echo "$BINDIR" | grep '/$')
		if [ "$chequeo" == "" ]
		then
			binPath="$BINDIR"'/'
		else
			binPath="$BINDIR"
		fi

		#Seteo demonio por default
		procesoAEjecutar='RecibirOfertas'
		funcionDetenerProceso="$binPath"'RecibirOfertas.sh'

		#Armo GraLog
		logDetenerProceso="$binPath"'GrabarBitacora.sh'

		#Chequeo que exista GrabarBitacora
		if [ -e "$logDetenerProceso" ]
		then

			#Chequeo parametros
			if [ "$2" != "" ] || [ "$4" != "" ]
			then

				#Chequeo comando que invoca
				if [ "$1" == "-i" ]
				then
					procesoQueLoInvoca="$2"
					hayFuncion=1
				else
					if [ "$3" == "-i" ]
					then
						procesoQueLoInvoca="$4"
						hayFuncion=1
					fi
				fi

				#Chequeo comando a ejecutar
				if [ "$1" == "-c" ]
				then
					procesoAEjecutar="$2"
					#Chequeo extension de la funcion
					chequeo=$(echo "$procesoAEjecutar" | grep '.sh$')
					if [ "$chequeo" == "" ]
					then
						funcionDetenerProceso="$binPath""$procesoAEjecutar"'.sh'
					else
						funcionDetenerProceso="$binPath""$procesoAEjecutar"
					fi

				else
					if [ "$3" == "-c" ]
					then
						procesoAEjecutar="$4"
						#Chequeo extension de la funcion
						chequeo=$(echo "$procesoAEjecutar" | grep '.sh$')
						if [ "$chequeo" == "" ]
						then
							funcionDetenerProceso="$binPath""$procesoAEjecutar"'.sh'
						else
							funcionDetenerProceso="$binPath""$procesoAEjecutar"
						fi
					fi
				fi

			fi

			#Chequeo que exista la funcion en memoria
			funcionEnProceso=$(echo ${funcionDetenerProceso##*/})
			psOut=$(ps -eo pid,args) # correr separado para que ps no muestre a grep corriendo
			chequeo=$(echo "$psOut" | grep "$funcionEnProceso")
			if [ "$chequeo" == "" ]
			then
				if [ "$hayFuncion" -eq 1 ]
				then

					comandoGrabarBitacora=$(echo ${procesoQueLoInvoca%.sh})
					"$logDetenerProceso" "$comandoGrabarBitacora" "No se puede detener: $procesoAEjecutar porque no esta en ejecucion" "ERR"
				else
					echo "Detener: No se puede detener $procesoAEjecutar porque no esta en ejecucion"
				fi
				pause 'Press [Enter] key to continue...'
				exit 1

			fi

			#Obtengo Id del proceso para matarlo
			funcionEnProceso=$(echo ${funcionDetenerProceso##*/})
			psOut=$(ps -eo pid,args) # correr separado para que ps no muestre a grep corriendo
			idProceso=$(echo "$psOut" | grep "$funcionEnProceso" | cut -d ' ' -f 1)
			numeroDeCampo=2

			while [ "$idProceso" == "" ]
			do
				psOut=$(ps -eo pid,args) # correr separado para que ps no muestre a grep corriendo
				idProceso=$(echo "$psOut" | grep "$funcionEnProceso" | cut -d ' ' -f "$numeroDeCampo")
				let numeroDeCampo="$numeroDeCampo"+1
			done

			if [ "$idProceso" != "" ]
			then
				#Detengo proceso
				kill "$idProceso"
				resultadoKill=$?

				#Logeo
				if [ "$hayFuncion" -eq 1 ]
				then
					comandoGrabarBitacora=$(echo ${procesoQueLoInvoca%.sh})

					if [ $resultadoKill -eq 0 ]
					then
						"$logDetenerProceso" "$comandoGrabarBitacora" "$procesoAEjecutar se detuvo correctamente"
						pause 'Press [Enter] key to continue...'
						exit 0
					else
						"$logDetenerProceso" "$comandoGrabarBitacora" "$procesoAEjecutar no se pudo detener" "ERR"
						pause 'Press [Enter] key to continue...'
						exit 1
					fi

				else

					if [ $resultadoKill -eq 0 ]
					then
						echo "Detener: "$procesoAEjecutar" se detuvo correctamente"
						pause 'Press [Enter] key to continue...'
						exit 0
					else
						echo "Detener: "$procesoAEjecutar" no se pudo detener"
						pause 'Press [Enter] key to continue...'
						exit 1
					fi

				fi

			else
				if [ "$hayFuncion" -eq 1 ]
				then
					comandoGrabarBitacora=$(echo ${procesoQueLoInvoca%.sh})
					"$logDetenerProceso" "$comandoGrabarBitacora" "No existe PID de $procesoAEjecutar" "ERR"
				else
					echo "Detener: No existe PID de "$procesoAEjecutar"" "ERR"
				fi
			fi

		else
			echo "Detener: no existe "$logDetenerProceso""
			pause 'Press [Enter] key to continue...'
			exit 1
		fi

	else
		echo "Detener: cantidad de parametros incorrecta"
		pause 'Press [Enter] key to continue...'
		exit 1
	fi

else
	echo "Detener: No se puede iniciar si no esta inicializado el ambiente"
	pause 'Press [Enter] key to continue...'
	exit 1
fi
