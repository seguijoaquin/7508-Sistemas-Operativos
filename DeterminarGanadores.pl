use strict;
use warnings;
use Switch;

my ($option, $idSorteo, $grupo) = @ARGV;
my $input = '';
my $grupo = 0;

if (not defined $idSorteo) {
	error_idSorteo();
}

if (defined $grupo) {
	#revisar el tipo de entrada para parsear
}

if(defined $option)
{
	if(($option != "-a") || ($option != "-g"))
	{
		error_opcion();
	}
	if($option == "-a")
	{
		mostrar_ayuda();
	}
	else
	{
		procesar();
	}
}

sub procesar
{
	while ($input ne '5')
	{
		clear_screen();

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

sub error_opcion
{
	#TODO: Error en la opcion de entrada
}

sub mostrar_ayuda
{
	#TODO: Mostrar ayuda, parametro de entrada -a
}

sub clear_screen
{
    system("clear");
}