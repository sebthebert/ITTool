=head1 NAME

ITTool::Monitoring::Software::MySQL - ITTool Monitoring for MySQL Software module

=cut

package ITTool::Monitoring::Software::MySQL;

use strict;
use warnings;

use Readonly;

Readonly my $BIN_MYSQL => '/usr/bin/mysql';

my %check = (
    #    'Software.MySQL.Database.List' => {
    #        fct  => \&Version,
    #        args => []
    #    },
    #    'Software.MySQL.Database.Size' => {
    #        fct  => \&Database_Size,
    #        args => []
    #    },
    #    'Software.MySQL.Table.List' => {
    #        fct  => \&Version,
    #        args => []
    #    },
    #    'Software.MySQL.Table.Size' => {
    #        fct  => \&Version,
    #        args => []
    #    },
    'Software.MySQL.Version' => {
        fct  => \&Version,
		type => 'version'
    },
);

=head1 FUNCTIONS

=head2 Checks_Available

=cut

sub Checks_Available
{
    my @list = ();
	
	foreach my $k (sort keys %check)
	{
		push @list, { name => $k, type => $check{$k}{type} };
	}
	
    return (@list);
}

=head2 Checks_Export

=cut

sub Checks_Export
{
    return (%check);
}

=head2 Database_Size($db)

=cut

sub Database_Size
{

#select table_schema, sum(data_length+index_length) from information_schema.TABLES GROUP BY table_schema ;
}

=head2 Table_Size($table)

=cut

sub Table_Size
{

    #select * from information_schema.tables;
}

=head2 Version

Returns MySQL version

=cut

sub Version
{
	if ($^O eq 'linux')
    {
		my @lines = `$BIN_MYSQL --version`;
        foreach my $l (@lines)
        {
            return ({ status => 'ok', data => { version => $1 } })  
                if ($l =~ /$BIN_MYSQL  Ver \d+(?:\.\d+)+ Distrib (\d+(\.\d+)+)/);
        }
	}

	return ({ status => 'error', data => 'Unable to get MySQL version.' });
}

1;

=head1 AUTHOR

Sebastien Thebert <stt@ittool.org>

=cut
