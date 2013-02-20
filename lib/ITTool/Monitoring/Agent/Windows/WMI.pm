=head1 NAME

ITTool::Monitoring::Agent::Windows::WMI - ITTool WMI (Windows Management Instrumentation) for Windows Monitoring Agent module

http://msdn.microsoft.com/en-us/library/windows/desktop/aa394585(v=vs.85).aspx

=cut

package ITTool::Monitoring::Agent::Windows::WMI;

use strict;
use warnings;

use DBI;
use Readonly;

Readonly my %QUERY =>
	(
	COMPUTER => 'SELECT * FROM Win32_ComputerSystem',
	DISK => 'SELECT * FROM Win32_LogicalDisk',
	PRINTER_DEFAULT => 'SELECT * FROM Win32_Printer WHERE Default = TRUE',
	PROCESSOR => 'SELECT * FROM Win32_Processor',
	);
	
my $dbh = DBI->connect('dbi:WMI:');

=head2 Query($query)

=cut

sub Query
{
	my $query = shift;
	
	my $sth = $dbh->prepare($QUERY{$query});
	$sth->execute();
	
	return ($sth->fetchrow);
}

1;

=head1 AUTHOR

Sebastien Thebert <stt@ittool.org>

=cut