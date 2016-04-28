#!/usr/bin/perl

use Getopt::Std;
use strict;
use Switch;
use warnings;

my %opts;
getopts('ag', \%opts) or die mostrar_ayuda();

if(defined $opts{a})
{
	mostrar_ayuda();
}
else
{
	my $idSorteo = shift or die error_idSorteo();
	my $grupo = shift or die error_grupo();
	#TODO: Ver manejo de grupos antes de procesar,
	#puede venir un solo numero (ej: 7),
	#un rango (7-9) o un conjunto (7,8,9)
	procesar();
}

sub procesar
{
	#Ejecucion de los procesos para determinar ganadores
	ejecutar_proceso();

	my $input = '';
	while ($input ne '5')
	{
		limpiar_pantalla();

		print "1. Resultado general del sorteo\n".
			  "2. Ganadores por sorteo\n".
			  "2. Ganadores por licitacion\n". 
			  "4. Resultados por grupo\n". 
			  "5. Salir\n";

		print "Seleccione una opción: ";
		$input = <STDIN>;
		chomp($input);

		switch ($input)
		{
			case '1'
			{
				$input = '';
				mostrar_resutado_general();
				$input = '';
			}
			case '2'
			{
				$input = '';
				mostrar_ganadores_sorteo();
				$input = '';
			}
			case '3'
			{
				$input = '';
				mostrar_ganadores_licitacion();
				$input = '';
			}
			case '4'
			{
				$input = '';
				mostrar_resultados_grupo();
				$input = '';
			}
		}
	}
}

sub ejecutar_proceso
{
	#TODO: Logica del proceso
}

sub mostrar_resultados_grupo
{
	#TODO: Mostrar resultados por grupo
}

sub mostrar_ganadores_licitacion
{
	#TODO: Mostrar ganadores licitacion
}

sub mostrar_ganadores_sorteo
{
	#TODO: Mostrar ganadores sorteo
}

sub mostrar_resutado_general
{
	#TODO: Mostrar resultado general
}

sub error_idSorteo
{
	print "No se ha encontrado el id de sorteo\n";
	exit 2;
}

sub error_grupo
{
	print "No se ha encontrado el o los grupos para operar\n";
	exit 3;
}

sub mostrar_ayuda
{
	print "Las opciones válidas son -a (ayuda) y -g (grabar a archivo).\n";
	exit 4;
}

sub limpiar_pantalla
{
    system("clear");
}
