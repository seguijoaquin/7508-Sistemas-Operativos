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
		funcionLanzarProceso="$binPath"'RecibirOfertas.sh'

		#Armo GrabarBitacora
		#logLanzarProceso="$binPath"'GrabarBitacora.sh'
		logLanzarProceso="./GrabarBitacora.sh"

		#Chequeo que exista GrabarBitacora
		if [ -e "$logLanzarProceso" ]
		then

			#Chequeo parametros
			if [ "$2" != "" ] || [ "$4" != "" ]
			then

				#Chequeo proceso que lo invoca
				#Si no se especifica comando que lo invoca, se asume desde shell
				#Y el log sera desde shell
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

				#Chequeo proceso a ejecutar
				if [ "$1" == "-c" ]
				then
					procesoAEjecutar="$2"
					#Chequeo extension de la funcion
					chequeo=$(echo "$procesoAEjecutar" | grep '.sh$')
					if [ "$chequeo" == "" ]
					then
						funcionLanzarProceso="$binPath""$procesoAEjecutar"'.sh'
					else
						funcionLanzarProceso="$binPath""$procesoAEjecutar"
					fi

				else
					if [ "$3" == "-c" ]
					then
						procesoAEjecutar="$4"
						#Chequeo extension de la funcion
						chequeo=$(echo "$procesoAEjecutar" | grep '.sh$')
						if [ "$chequeo" == "" ]
						then
							funcionLanzarProceso="$binPath""$procesoAEjecutar"'.sh'
						else
							funcionLanzarProceso="$binPath""$procesoAEjecutar"
						fi
					fi
				fi

				#Chequeo que exista la funcion
				chequeo=$(ls "$binPath" | grep "$procesoAEjecutar")
				if [ "$chequeo" == "" ]
				then
					if [ "$hayFuncion" -eq 1 ] #ES INVOCADO DESDE DENTRO DE UN SCRIPT
					then
						comandoGrabarBitacora=$(echo ${procesoQueLoInvoca%.sh})
						"$logLanzarProceso" "$procesoQueLoInvoca" "No se puede lanzar $procesoAEjecutar porque no existe" "ERR"
					else
						echo "LanzarProceso: No se puede lanzar "$procesoAEjecutar" porque no existe"
					fi
					pause 'Press [Enter] key to continue...'
					exit 1

				fi

			fi

			#Chequeo que no este corriendo el proceso
			psOut=$(ps -eo pid,args) # correr separado para que ps no muestre a grep corriendo
			chequeo=$(echo "$psOut" | grep "$funcionLanzarProceso")
			if [ "$chequeo" != "" ]
			then
				#Muestro el error de ya esta corriendo
				if [ "$hayFuncion" -eq 1 ]
				then
					comandoGrabarBitacora=$(echo ${procesoQueLoInvoca%.sh})
					"$logLanzarProceso" "$procesoQueLoInvoca" "No se puede lanzar $procesoAEjecutar porque ya esta en ejecucion" "ERR"
				else
					echo "LanzarProceso: No se puede lanzar "$procesoAEjecutar" porque ya esta en ejecucion"
				fi
				pause 'Press [Enter] key to continue...'
				exit 1

			else

				#Chequeo que exista funcion a lanzar
				if [ -e "$funcionLanzarProceso" ]
				then

					#Arranco proceso
					"$funcionLanzarProceso" &
					resultadoLanzarProceso=$?
					ps_Out=$(ps -eo pid,args) # correr separado para que ps no muestre a grep corriendo
					procesoAEjecutar_ID=$( echo "$ps_Out" | grep "$procesoAEjecutar" )
					procesoAEjecutar_ID=( $procesoAEjecutar_ID )
					procesoAEjecutar_ID=${procesoAEjecutar_ID[0]}

					#Logeo
					if [ "$hayFuncion" -eq 1 ]
					then
						comandoGrabarBitacora=$(echo ${procesoQueLoInvoca%.sh})

						if [ $resultadoLanzarProceso -eq 0 ]
						then
							"$logLanzarProceso" "$procesoQueLoInvoca" "$procesoAEjecutar se inicio correctamente con id: <$procesoAEjecutar_ID>" "INFO"
							pause 'Press [Enter] key to continue...'
							exit 0
						else
							"$logLanzarProceso" "$procesoQueLoInvoca" "$procesoAEjecutar no se pudo iniciar" "ERR"
							pause 'Press [Enter] key to continue...'
							exit 1
						fi

					else

						if [ $resultadoLanzarProceso -eq 0 ]
						then
							echo "LanzarProceso: "$procesoAEjecutar" se inicio correctamente id: <$procesoAEjecutar_ID>"
							pause 'Press [Enter] key to continue...'
							exit 0
						else
							echo "LanzarProceso: "$procesoAEjecutar" no se pudo iniciar"
							pause 'Press [Enter] key to continue...'
							exit 1
						fi

					fi

				else
					echo "LanzarProceso: no existe "$funcionLanzarProceso""
				fi

			fi

		else
			echo "LanzarProceso: cantidad de parametros incorrecta"
			pause 'Press [Enter] key to continue...'
			exit 1
		fi

	else
		echo "LanzarProceso: no existe "$logLanzarProceso""
	fi

else
	echo "LanzarProceso: No se puede iniciar si no esta inicializado el ambiente"
	pause 'Press [Enter] key to continue...'
	exit 1
fi
