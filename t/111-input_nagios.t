use strict;
use warnings;
use Data::Dumper;
use Test::More tests => 4;

use_ok('Monitoring::TT');
use_ok('Monitoring::TT::Input::Nagios');

##################################################
# set it twice to avoid 'used only once:' warning
$Monitoring::TT::Log::Verbose = 0;
$Monitoring::TT::Log::Verbose = 0;
my $nag       = Monitoring::TT::Input::Nagios->new();
my $types     = $nag->get_types(['t/data/111-input_nagios']);
my $types_exp = ['hosts'];
is_deeply($types, $types_exp, 'nagios input types') or diag(Dumper($types));

my $hosts     = $nag->read('t/data/111-input_nagios', 'hosts');
my $hosts_exp =  [{
            'groups'                => [],
            'type'                  => 'windows',
            'apps'                  => {},
            'tags'                  => {},
            'conf'                  => {
                    '_some_other_cust_var'  => 'foo',
                    'use'                   => 'generic-host',
                    'host_name'             => 'test-win',
                    'address'               => '127.0.0.2',
                    'contact_groups'        => 'test-contact',
                },
          },
          {
            'apps' => {
                        'database'  => '',
                        'webserver' => ''
                      },
            'tags' => {
                        'debian' => '',
                        'https'  => '',
                        'http'   => '80',
                      },
            'groups' => [],
            'type' => 'linux',
            'conf'                  => {
                    'use' => 'generic-host',
                    'host_name' => 'test-host',
                    'address' => '127.0.0.1',
                    'contact_groups' => 'test-contact',
                }
          }
        ];
is_deeply($hosts, $hosts_exp, 'input parser') or diag(Dumper($hosts));
