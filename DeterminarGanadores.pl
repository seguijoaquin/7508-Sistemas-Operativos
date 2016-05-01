#!/usr/bin/perl

use Getopt::Std;
use strict;
use Switch;
use warnings;
use Text::CSV;

my %opts;
my %padron;
my %ganadores_sorteo;
my %ganadores_licitacion;
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
	ganadores_por_sorteo();
}

sub ganadores_por_sorteo
{
	my $csv_padron = Text::CSV->new({ caracter => ';' });
	my $file_padron = "archivo padron";	#TODO: poner nombre archivo correcto
	open(my $data_padron, '<', $file_padron) or die "No se puede abrir el archivo '$file_padron' $!\n";
	
	my $csv_sorteo = Text::CSV->new({ caracter => ';' });
	my $file_sorteo = "archivo sorteo";	#TODO: poner nombre archivo correcto
	open(my $data_sorteo, '<', $file_sorteo) or die "No se puede abrir el archivo '$file_sorteo' $!\n";
	
	my $csv_grupo = Text::CSV->new({ caracter => ';' });
	my $file_grupo = "archivo grupo";	#TODO: poner nombre archivo correcto
	open(my $data_grupo, '<', $file_grupo) or die "No se puede abrir el archivo '$file_grupo' $!\n";
	
	my @datos_ganador; #Array con los datos del ganador
	my $numero_menor = 168;
	my $participa = 0;
	
	foreach my $g (@lista_grupos) {
		#Analizo si el grupo participa - grupo ABIERTO
		$participa = 0;
		while (my $line_grupo = <$data_grupo>) {
		  chomp $line_grupo;
		  if ($csv_grupo->parse($line_grupo)) {
			  my @fields_grupo = $csv_grupo->fields_grupo();
			  if($fields_grupo[0] == $g)
			  {
				if($fields_grupo[1] eq "ABIERTO")
				{
					$participa = 1;
				}
			  }
		  } else {
			  warn "Error en el formato de línea en: $line_padron\n";
		  }
		}
	
		if($participa == 1)
		{
			#Cargo el nombre y el orden segun el archivo de padrones
			while (my $line_padron = <$data_padron>) {
			  chomp $line_padron;
			  if ($csv_padron->parse($line_padron)) {
				  my @fields_padron = $csv_padron->fields_padron();
				  if($fields_padron[0] == $g) #Si el campo grupo es el grupo sobre el que estoy procesando
				  {
					if(($fields_padron[5] == 1) || ($fields_padron[5] == 2)) #Si participa, lo agrego al hash
					{
						$padron{$fields_padron[1]} = $fields_padron[2];
					}
				  }
			  } else {
				  warn "Error en el formato de línea en: $line_padron\n";
			  }
			}
			
			#Veo ganador segun el archivo de sorteos
			$numero_menor = 168;
			@datos_ganador=(); 
			
			while (my $line_sorteo = <$data_sorteo>) {
			  chomp $line_sorteo;
			  if ($csv_sorteo->parse($line_sorteo)) {
				  my @fields_sorteo = $csv_sorteo->fields_sorteo();
				  for my $p (keys %padron) {
					 if($fields_sorteo[0] == $p) 
					 {
						if($fields_sorteo[1] < $numero_menor)
						{
							$numero_menor = $fields_sorteo[1];
							$datos_ganador.push($p); #Orden
							$datos_ganador.push($fields_sorteo[1]); #Sorteo
							$datos_ganador.push($padron{$p}); #Nombre
						}
					 }
				  }
			  } else {
				  warn "Error en el formato de línea en: $line_sorteo\n";
			  }
			}
			#Meto en el hash como clave el sorteo y como dato el orden
			$ganadores_sorteo{$g} = $datos_ganador;
		}
	}
}

sub ganadores_por_licitacion
{

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
	#TODO: poner el titulo
	foreach my $s (keys %ganadores_sorteo) {	
			print "$s - $ganadores_sorteo{$s}[0] S $ganadores_sorteo{$s}[2]\n";
			print "$s - $ganadores_licitacion{$s}[0] L $ganadores_licitacion{$s}[2]\n";
		}
	}
}

sub mostrar_ganadores_licitacion
{
	#TODO: Mostrar ganadores licitacion
}

sub mostrar_ganadores_sorteo
{
	#TODO: poner el titulo
	foreach my $g (keys %ganadores_sorteo) {
			print "Ganador por sorteo del grupo $g Nro de Orden: $ganadores_sorteo{$g}[0], $ganadores_sorteo{$g}[2] (Nro deSorteo $ganadores_sorteo{$g}[1])\n";
	}
}

sub mostrar_resutado_general
{
	my $csv = Text::CSV->new({ caracter => ';' });
	my $file = "archivo sorteo";	#TODO: poner nombre archivo correcto
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