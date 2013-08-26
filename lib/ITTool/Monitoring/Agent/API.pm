=head1 NAME

ITTool::Monitoring::Agent::API - ITTool Monitoring Agent API module

=cut
package ITTool::Monitoring::Agent::API;

use strict;
use warnings;

use Exporter 'import';
use FindBin;
use JSON;
use Readonly;

use lib "$FindBin::Bin/../lib/";
use ITTool::Monitoring::Agent;

our @EXPORT_OK = qw(%agent_api);

Readonly my $API_ROOT => '/api/itt_monitoring_agent';

our %agent_api = (
    "$API_ROOT/version" => {
        method => 'GET',
        action => sub {
            my ($self) = @_;
            return (to_json($self->Version())); 
			} 
		},
    "$API_ROOT/checks_available" => {
        method => 'GET',
        action => sub {
            my ($self) = @_;
            return (to_json([$self->Checks_Available()])); 
			} 
		},
    "$API_ROOT/get_config" => {
        method => 'GET',
        action => sub {
            my ($self) = @_;
            #my @checks = @{$self->{checks}}; #Checks_List();
            
            return (to_json([$self->Checks_List()])); 
            } 
        },
    "$API_ROOT/get_data" => { 
        method => 'GET', 
        action => sub {
            my ($self, $check) = @_;
            return (to_json($self->Check($check)));         
            } 
        },
#    "$API_ROOT/set_config" =>
#        { method => 'POST', action => \&Set_Config },
#    "$API_ROOT/upload_app_module" =>
#        { method => 'POST', action => \&Upload_App_Module },
    );


1;

=head1 AUTHOR

Sebastien Thebert <stt@ittool.org>

=cut