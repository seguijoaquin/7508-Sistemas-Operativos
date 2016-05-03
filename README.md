# 75.08 Sistemas Operativos
## Grupo 7

Instrucciones para arrancar el SO desde puerto USB y loguearse con usuario de ubuntu por defecto.

1) Conectar el pendrive a un puerto trasero de la máquina.

2) Encender la máquina abriendo las opciones de booteo en caso de que automaticamente no bootee desde el USB (F1 / F2 / F8)

3) Esperar que inicie la instalacion de Ubuntu y seleccionar idioma español

4) Hacer click en la opcion de Probar Sistema Operativo

5) Ahora se encuentra el sistema iniciado y logueado con el usuario de ubuntu por defecto.

------------------------------------------------------------------------

Sistema CIPAK

Para instalar el sistema:
	
	1. Iniciar terminal.
	

	2. Instalar los paquetes:
		libswitch-perl ( ejecutar comando: sudo apt -get install libswitch-perl )
		libtext-csv-perl ( ejecutar comando: sudo apt -get install libtext-csv-perl )


	3. Copiar el archivo GRUPO7.tgz a la carpeta en la que quiere realizar la instalación:
		$ cp [ruta_paquete]/GRUPO7.tgz [ruta_instalacion]

	4. ir a la carpeta de instalación y extraer el contenido del paquete de instalación:
		$ cd [ruta_instalacion]
		$ tar -xvf GRUPO7.tgz

	5. asignar permisos de ejecución al instalador AFINSTAL.sh:
		$ cd GRUPO7
		$ chmod u+rx INSTALL.sh

	6. Ejecutar el instalador:
		$ ./INSTALL.sh

	7. Continuar con las indicaciones del instalador
	
	8. Instalacion exitosa, se crean los directorios configurados dentro de la carpeta GRUPO7/
	
	9. Para obtener mas información acerca de los pasos realizados durante la instalacion revisar archivo log que se encuentra en /Grupo7/bitacora/Install.log
	
 

Para inicializar las variables:

