#!/usr/bin/perl

use constant {
	GRUPO_INVALIDO => -1,
	GRUPO_NO_ABIERTO => -2,
	GRUPO_SIN_OFERTAS => -3
};

use Getopt::Std;
use strict;
use Switch;
use warnings;
use Text::CSV;

my $INFODIR = $ENV{INFODIR};
my $PROCDIR = $ENV{PROCDIR};
my $MAEDIR = $ENV{MAEDIR};
my %opts;
my @lista_grupos;
my %sorteo;
my %ganadores_sorteo;
my %ganadores_licitacion;
my $graba_file;
my $archivo_sorteo;
my $fecha_adj;
my $idSorteo;
my $file_sorteo_out;

getopts('ag', \%opts) or die mostrar_ayuda();

$graba_file = defined $opts{g};
if (defined $opts{a})
{
	mostrar_ayuda();
}
else
{
	$archivo_sorteo = shift or die error_idSorteo();
	($idSorteo, $fecha_adj) = split('_', $archivo_sorteo);
	my $grupos = shift or die error_grupos();
	@lista_grupos = analizar_grupos($grupos);
	flock(DATA, 6) or die error_lock(); # 6 = non-blocking lock

	if ($graba_file)
	{
		open $file_sorteo_out, ">>", "${INFODIR}/$archivo_sorteo" or die "Can't open '${INFODIR}/$archivo_sorteo'\n";
	}
	procesar(@lista_grupos);
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
		      "3. Ganadores por licitacion\n". 
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
				$input = <STDIN>;
				$input = '';
			}
			case '2'
			{
				$input = '';
				mostrar_ganadores_sorteo();
				$input = <STDIN>;
				$input = '';
			}
			case '3'
			{
				$input = '';
				mostrar_ganadores_licitacion();
				$input = <STDIN>;
				$input = '';
			}
			case '4'
			{
				$input = '';
				mostrar_resultados_grupo();
				$input = <STDIN>;
				$input = '';
			}
		}
	}
}

sub ejecutar_proceso
{
	ganadores_por_sorteo();
	ganadores_por_licitacion();
}

sub obtener_info_grupos
{
	my %info_grupos;
	my $csv_grupo = Text::CSV->new({ sep_char => ';' }) or die "Cannot use CSV: ".Text::CSV->error_diag ();
	my $file_grupo = "$MAEDIR/grupos.mae";
	open(my $data_grupo, '<:encoding(iso8859-1)', $file_grupo) or die "No se puede abrir el archivo '$file_grupo' $!\n";
	while (my $line_grupo = <$data_grupo>)
	{
		chomp $line_grupo;
		if ($csv_grupo->parse($line_grupo))
		{
			my @fields_grupo = $csv_grupo->fields();
			$info_grupos{$fields_grupo[0]} = [@fields_grupo]; # la clave es el número de grupo
		}
		else
		{
			warn "Error en el formato de línea en: $line_grupo\n";
		}
	}

	return %info_grupos;
}

sub ganadores_por_sorteo
{
	my $csv_sorteo = Text::CSV->new({ sep_char => ';' }) or die "Cannot use CSV: ".Text::CSV->error_diag ();
	my $file_sorteo = "$PROCDIR/sorteos/$archivo_sorteo";
	open(my $data_sorteo, '<:encoding(iso8859-1)', $file_sorteo) or die "No se puede abrir el archivo '$file_sorteo' $!\n";

	my %info_grupos = obtener_info_grupos();

	foreach my $g (@lista_grupos)
	{
		my $fields_grupo_ptr = $info_grupos{$g};
		if (! defined $fields_grupo_ptr)
		{
			$ganadores_sorteo{$g} = GRUPO_INVALIDO;
			print "$g - El grupo $g no es un grupo válido.\n";
		}
		else
		{
			my @fields_grupo = @{$fields_grupo_ptr};
			if ($fields_grupo[1] ne "ABIERTO")
			{
				$ganadores_sorteo{$g} = GRUPO_NO_ABIERTO;
				print "$g - El grupo $g no participa por no estar abierto.\n";
			}
			else
			{
				my @datos_ganador; #Array con los datos del ganador
				#Cargo el nombre y el orden segun el archivo de padrones
				my %padron;
				my $csv_padron = Text::CSV->new({ sep_char => ';' }) or die "Cannot use CSV: ".Text::CSV->error_diag ();
				my $file_padron = "$MAEDIR/temaK_padron.mae";
				open(my $data_padron, '<:encoding(iso8859-1)', $file_padron) or die "No se puede abrir el archivo '$file_padron' $!\n";
				while (my $line_padron = <$data_padron>)
				{
					chomp $line_padron;
					if ($csv_padron->parse($line_padron))
					{
						my @fields_padron = $csv_padron->fields();
						$fields_padron[1] = $fields_padron[1] * 1; # lo convierto a entero
						$fields_padron[5] = $fields_padron[5] =~ /\S/ ? $fields_padron[5] * 1 : -1; # lo convierto a entero
						if ($fields_padron[0] == $g) #Si el campo grupo es el grupo sobre el que estoy procesando
						{
							if (($fields_padron[5] == 1) || ($fields_padron[5] == 2)) #Si participa, lo agrego al hash
							{
								$padron{$fields_padron[1]} = $fields_padron[2];
							}
						}
					}
					else
					{
						warn "Error en el formato de línea en: $line_padron\n";
					}
				}

				#Veo ganador segun el archivo de sorteos
				my $numero_menor = 169;
				@datos_ganador=(); 

				my %info_sorteo = obtener_info_sorteo();
				for my $p (keys %padron)
				{
					my $numero_de_sorteo = @{$info_sorteo{$p}}[1];
					if ($graba_file)
					{
						print $file_sorteo_out "Numero de Sorteo $numero_de_sorteo, le corresponde al orden $p\n";
					}
					if ($numero_de_sorteo < $numero_menor)
					{
						$numero_menor = $numero_de_sorteo;
						@datos_ganador=($p, $numero_de_sorteo, $padron{$p}); #Orden, Sorteo, Nombre
					}
				}

				#Meto en el hash como clave el sorteo y como dato el orden
				$ganadores_sorteo{$g} = [@datos_ganador];
				if ($graba_file)
				{
					my @ganador = @{$ganadores_sorteo{$g}};
					open my $file_gansorteo, ">>:encoding(iso8859-1)", "${INFODIR}/${idSorteo}_Grd$lista_grupos[0]-Grh$lista_grupos[$#lista_grupos]_${fecha_adj}_S" or die "Can't open '${INFODIR}/${idSorteo}_Grd$lista_grupos[0]-Grh$lista_grupos[$#lista_grupos]_${fecha_adj}_S'\n";
					print $file_gansorteo "Ganador por sorteo del grupo $g Nro de Orden: $ganador[0], $ganador[2] (Nro de Sorteo $ganador[1])\n";
					open my $file_resultgrupo, ">>:encoding(iso8859-1)", "${INFODIR}/${idSorteo}_Grupo${g}_${fecha_adj}" or die "Can't open '${INFODIR}/${idSorteo}_Grupo${g}_${fecha_adj}'\n";
					print $file_resultgrupo "Ganador por sorteo del grupo $g Nro de Orden: $ganador[0], $ganador[2] (Nro de Sorteo $ganador[1])\n";
				}
			}
		}
	}
}

sub obtener_info_licitacion
{
	my %info_validas;
	my $csv_validas = Text::CSV->new({ sep_char => ';' }) or die "Cannot use CSV: ".Text::CSV->error_diag ();
	my @fecha_validas_partes = split('-', $fecha_adj);
	my $file_validas= "$PROCDIR/validas/${fecha_validas_partes[2]}${fecha_validas_partes[1]}${fecha_validas_partes[0]}";
	open(my $data_validas, '<:encoding(iso8859-1)', $file_validas) or die "No se puede abrir el archivo '$file_validas' $!\n";
	while (my $line_validas = <$data_validas>)
	{
		chomp $line_validas;
		if ($csv_validas->parse($line_validas))
		{
			my @fields_validas = $csv_validas->fields();
			$fields_validas[4] = $fields_validas[4] * 1; # convertimos a entero
			$fields_validas[5] =~ s/\,/\./; # Reemplazo la coma decimal por punto para que sea variable numérica
			# la clave es el número de grupo
			if (! defined $info_validas{$fields_validas[3]})
			{
				$info_validas{$fields_validas[3]} = [[@fields_validas]];
			}
			else
			{
				push @{@info_validas{$fields_validas[3]}}, [@fields_validas];
			}
		}
		else
		{
			warn "Error en el formato de línea en: $line_validas\n";
		}
	}

	return %info_validas;
}

sub obtener_info_sorteo
{
	my %info_sorteo;
	my $csv_sorteo = Text::CSV->new({ sep_char => ';' }) or die "Cannot use CSV: ".Text::CSV->error_diag ();
	my $file_sorteo = "$PROCDIR/sorteos/$archivo_sorteo";
	open(my $data_sorteo, '<:encoding(iso8859-1)', $file_sorteo) or die "No se puede abrir el archivo '$file_sorteo' $!\n";
	while (my $line_sorteo = <$data_sorteo>)
	{
		chomp $line_sorteo;
		if ($csv_sorteo->parse($line_sorteo))
		{
			my @fields_sorteo = $csv_sorteo->fields();
			$info_sorteo{$fields_sorteo[0]} = [@fields_sorteo];
		}
		else
		{
			warn "Error en el formato de línea en: $line_sorteo\n";
		}
	}

	return %info_sorteo;
}

sub ganadores_por_licitacion
{
	my %info_licitacion = obtener_info_licitacion();
	my %info_grupos = obtener_info_grupos();
	my %info_sorteo = obtener_info_sorteo();

	foreach my $g (@lista_grupos)
	{
		if (! defined $info_grupos{$g})
		{
			$info_grupos{$g} = GRUPO_INVALIDO;
		}

		if ($info_grupos{$g} == GRUPO_INVALIDO or $info_grupos{$g} == GRUPO_NO_ABIERTO)
		{
			$ganadores_licitacion{$g} = $info_grupos{$g};
			if ($graba_file)
			{
				open my $file_ganlicit, ">>", "${INFODIR}/${idSorteo}_Grd$lista_grupos[0]-Grh$lista_grupos[$#lista_grupos]_${fecha_adj}_L" or die "Can't open '${INFODIR}/${idSorteo}_Grd$lista_grupos[0]-Grh$lista_grupos[$#lista_grupos]_${fecha_adj}_L'\n";
				print $file_ganlicit "No hubo ganador por licitación del grupo $g.\n";
				open my $file_resultgrupo, ">>", "${INFODIR}/${idSorteo}_Grupo${g}_${fecha_adj}" or die "Can't open '${INFODIR}/${idSorteo}_Grupo${g}_${fecha_adj}'\n";
				print $file_resultgrupo "No hubo ganador por licitación del grupo $g.\n";
			}
		}
		else
		{
			my $fields_validas2_ptr = $info_licitacion{$g};
			if (! defined $fields_validas2_ptr)
			{
				$ganadores_licitacion{$g} = GRUPO_SIN_OFERTAS;
			}
			else
			{
				my $mayor_oferta = 0;
				my @fields_validas2 = @{$fields_validas2_ptr};
				my @datos_ganador;
				# itera cada una de las ofertas válidas del grupo
				foreach my $fields_validas_ptr (@fields_validas2)
				{
					my $ganador_sorteo = $ganadores_sorteo{$g}[0]; # el orden del ganador del sorteo
					my @fields_validas = @{$fields_validas_ptr};
					if ($fields_validas[4] != $ganador_sorteo) # Si el que licitó es el ganador por sorteo, lo ignoramos
					{
						if ($fields_validas[5] > $mayor_oferta)
						{
							$mayor_oferta = $fields_validas[5];
							#Orden, Importe, Nombre, Sorteo
							my $orden_sorteo_actual = @{$info_sorteo{$fields_validas[4]}}[1];
							@datos_ganador=($fields_validas[4], $fields_validas[5], $fields_validas[6], $orden_sorteo_actual);
						}
						elsif ($fields_validas[5] == $mayor_oferta) #En caso de empate, desempatar por sorteo
						{
							my $orden_sorteo_actual = @{$info_sorteo{$fields_validas[4]}}[1];
							if ($orden_sorteo_actual < $datos_ganador[3]) #Si el order de sorteo del actual en proceso es mejor al que ya existe, entonces lo cambio
							{
								$mayor_oferta = $fields_validas[5];
								#Orden, Importe, Nombre, Sorteo
								@datos_ganador=($fields_validas[4], $fields_validas[5], $fields_validas[6], $orden_sorteo_actual);
							}
						}
					}
				}

				# TODO manejar ! defined @datos_ganador
				$ganadores_licitacion{$g} = @datos_ganador ? [@datos_ganador] : GRUPO_SIN_OFERTAS;
				if ($graba_file)
				{
					open my $file_ganlicit, ">>", "${INFODIR}/${idSorteo}_Grd$lista_grupos[0]-Grh$lista_grupos[$#lista_grupos]_${fecha_adj}_L" or die "Can't open '${INFODIR}/${idSorteo}_Grd$lista_grupos[0]-Grh$lista_grupos[$#lista_grupos]_${fecha_adj}_L'\n";
					print $file_ganlicit "Ganador por licitación del grupo $g: Numero de orden $ganadores_licitacion{$g}[0],  $ganadores_licitacion{$g}[2] con $ganadores_licitacion{$g}[1] (Nro de Sorteo  $ganadores_licitacion{$g}[3])\n";
					open my $file_resultgrupo, ">>", "${INFODIR}/${idSorteo}_Grupo${g}_${fecha_adj}" or die "Can't open '${INFODIR}/${idSorteo}_Grupo${g}_${fecha_adj}'\n";
					print $file_resultgrupo "Ganador por licitación del grupo $g: Numero de orden $ganadores_licitacion{$g}[0],  $ganadores_licitacion{$g}[2] con $ganadores_licitacion{$g}[1] (Nro de Sorteo  $ganadores_licitacion{$g}[3])\n";
				}
			}
		}
	}
}

sub analizar_grupos
{
	my ($grupos) = @_;
	my @partes = split('-', $grupos);
	if (@partes == 2)
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
	print "Ganadores por Grupo en el acto de adjudicación de fecha $fecha_adj, Sorteo: $idSorteo)\n";
	foreach my $g (@lista_grupos)
	{
		my $ganador_ptr = $ganadores_sorteo{$g};
		if ($ganador_ptr == GRUPO_INVALIDO)
		{
			print "$g - No hubo ganador por sorteo por ser un grupo inválido\n"
		}
		elsif ($ganador_ptr == GRUPO_NO_ABIERTO)
		{
			print "$g - No hubo ganador por sorteo por no estar abierto el grupo\n"
		}
		else
		{
			my @ganador = @{$ganador_ptr};
			print "$g - $ganador[0] S $ganador[2]\n";
		}

		$ganador_ptr = $ganadores_licitacion{$g};
		if ($ganador_ptr == GRUPO_INVALIDO)
		{
			print "$g - No hubo ganador por licitación por ser un grupo inválido\n"
		}
		elsif ($ganador_ptr == GRUPO_NO_ABIERTO)
		{
			print "$g - No hubo ganador por licitación por no estar abierto el grupo\n"
		}
		elsif ($ganador_ptr == GRUPO_SIN_OFERTAS)
		{
			print "$g - No hubo ganador por licitación por no haber ofertas\n"
		}
		else
		{
			my @ganador = @{$ganador_ptr};
			print "$g - $ganador[0] L $ganador[2]\n";
		}
	}
}

sub mostrar_ganadores_licitacion
{
	print "Ganadores por Licitación $idSorteo de fecha $fecha_adj\n";
	foreach my $g (@lista_grupos)
	{
		my $ganador_ptr = $ganadores_licitacion{$g};
		if ($ganador_ptr == GRUPO_INVALIDO)
		{
			print "$g - No hubo ganador por licitación por ser un grupo inválido\n"
		}
		elsif ($ganador_ptr == GRUPO_NO_ABIERTO)
		{
			print "$g - No hubo ganador por licitación por no estar abierto el grupo\n"
		}
		elsif ($ganador_ptr == GRUPO_SIN_OFERTAS)
		{
			print "$g - No hubo ganador por licitación por no haber ofertas\n"
		}
		else
		{
			my @ganador = @{$ganador_ptr};
			print "Ganador por licitación del grupo $g: Numero de orden $ganador[0], $ganador[2] con $ganador[1] (Nro de Sorteo $ganador[3])\n";
		}
	}
}

sub mostrar_ganadores_sorteo
{
	print "Ganadores del Sorteo $idSorteo de fecha $fecha_adj\n";
	foreach my $g (@lista_grupos)
	{
		my $ganador_ptr = $ganadores_sorteo{$g};
		if ($ganador_ptr)
		{
			my @ganador = @{$ganador_ptr};
			print "Ganador por sorteo del grupo $g Nro de Orden: $ganador[0], $ganador[2] (Nro de Sorteo $ganador[1])\n";
		}
		else
		{
			print "No hubo ganador por sorteo del grupo $g.\n"
		}
	}
}

sub mostrar_resutado_general
{
	my $csv = Text::CSV->new({ sep_char => ';' });
	my $file = "$PROCDIR/sorteos/$archivo_sorteo";
	open(my $data, '<:encoding(iso8859-1)', $file) or die "No se puede abrir el archivo '$file' $!\n";
	while (my $line = <$data>)
	{
		chomp $line;
		if ($csv->parse($line))
		{
			my @fields = $csv->fields();
			print "Nro. de Sorteo $fields[0], le correspondió al número de orden $fields[1]\n";
		}
		else
		{
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
	# system("clear");
}

# Esto nos permite usar un lock sin tener que crear un nuevo archivo,
#  usando el filehandle <DATA>
__END__
