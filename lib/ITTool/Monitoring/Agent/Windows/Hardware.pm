=head1 NAME

ITTool::Monitoring::Agent::Windows::Hardware - ITTool Windows Hardware Monitoring Agent module

=cut

package ITTool::Monitoring::Agent::Windows::Hardware;

use strict;
use warnings;

use ITTool::Monitoring::Agent::Windows::WMI;

=head1 FUNCTIONS

=head2 CPU_Info()

=cut

sub CPU_Info
{	
	while (my @row = ITTool::Monitoring::Agent::Windows::WMI::Query('PROCESSOR'))
	{
		my $p = $row[0];
		
		return ({ status => 'ok', data => { 
			Name => $p->{name}, Description => $p->{Description} } });
	}

    return ({ status => 'error', 
		data => "Unable to get default printer" });
}


=head2 Printer_Default()

=cut

sub Printer_Default
{
	while (my @row = ITTool::Monitoring::Agent::Windows::WMI::Query('PRINTER_DEFAULT'))
	{
		my $printer = $row[0];
		
		return ({ status => 'ok', data => { Name => $printer->{Name} }});
	}

    return ({ status => 'error', 
		data => "Unable to get default printer" });
}

1;

=head1 AUTHOR

Sebastien Thebert <stt@ittool.org>

=cut