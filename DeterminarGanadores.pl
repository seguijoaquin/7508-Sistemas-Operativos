#!/usr/bin/perl

use Getopt::Std;
use strict;
use Switch;
use warnings;
use Text::CSV;

my %opts;
getopts('ag', \%opts) or die mostrar_ayuda();

if(defined $opts{a})
{
	mostrar_ayuda();
}
else
{
	my $idSorteo = shift or die error_idSorteo();
	my $grupos = shift or die error_grupos();
	my @lista_grupos = analizar_grupos($grupos);
	flock(DATA, 6) or die error_lock(); # 6 = non-blocking lock
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

sub analizar_grupos
{
	my ($grupos) = @_;
	my @partes = split('-', $grupos);
	if(@partes == 2)
	{
		return $partes[0]..$partes[1];
	}
	else
	{
		@partes = split(',', $grupos);
		return @partes;
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
	my $csv = Text::CSV->new({ caracter => ',' });
	my $file = "archivo sorteo";
	open(my $data, '<', $file) or die "No se puede abrir el archivo '$file' $!\n";
	while (my $line = <$data>) {
	  chomp $line;
	  if ($csv->parse($line)) {
		  my @fields = $csv->fields();
		  print "Nro. de Sorteo $fields[0], le correspondió al número de orden $fields[1]\n";
	  } else {
		  warn "Error en el formato de línea en: $line\n";
	  }
	}
}

sub error_lock
{
	print "Ya existe otro comando DeterminarGanadores en ejecución\n";
	exit 2;
}

sub error_idSorteo
{
	print "No se ha encontrado el id de sorteo\n\n";
	mostrar_ayuda();
}

sub error_grupos
{
	print "No se ha encontrado el o los grupos para operar\n\n";
	mostrar_ayuda();
}

sub mostrar_ayuda
{
	print "Uso: DeterminarGanadores.pl [OPCION]... [IDSORTEO] [GRUPO]\n"
	     ."Permite simular una licitación y muestra los resultados generales, por sorteo,\n"
	     ."por licitación, o por grupo.\n\n"
	     ."  -a                  Muestra la ayuda del programa (esta pantalla).\n"
	     ."  -g                  Graba el resultado en un archivo.\n\n"
	     ."IDSORTEO debe ser el nombre de uno de los archivos de sorteo procesados.\n"
	     ."Por ejemplo '2_18-02-2016'. El archivo de sorteo correspondiente debe existir.\n\n"
	     ."GRUPO debe ser una de las siguientes:\n"
	     ." un único número de grupo,\n"
	     ." un rango de grupos especificado como inicio y fin separados por un guión (e.g. '23-45'),\n"
	     ." una lista de grupos separados por coma, sin espacios (e.g. '23,12,3').\n\n"
	     ."Estado de salida:\n"
	     ." 0  si no hubo ningún problema,\n"
	     ." 1  si algún parámetro es incorrecto o se especificaron opciones inválidas.\n";
	exit 0;
}

sub limpiar_pantalla
{
	system("clear");
}

# Esto nos permite usar un lock sin tener que crear un nuevo archivo,
#  usando el filehandle <DATA>
__END__