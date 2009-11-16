use warnings;
use strict;

package Net::FTPSSL::Robust;
use base 'Net::FTP::Robust', 'Exporter';

our @EXPORT =
  qw/SECURITY_TLS
     SECURITY_SSL/;

use Log::Report 'net-ftpssl-robust', syntax => 'SHORT';

use Net::FTPSSL;
# Gladly, ::FTPSSL has some level of interface compatibility with Net::FTP

use constant
 { SECURITY_TLS => 'TLS'
 , SECURITY_SSL => 'SSL'
 };

=chapter NAME

Net::FTPSSL::Robust - download files over FTP

=chapter SYNOPSIS

 use Net::FTPSSL;          # will publish some constants
 use Net::FTPSSL::Robust;  # more constants

 my $ftp = Net::FTPSSL::Robust->new
  ( Host     => $host
  , Security => SECURITY_TLS
  );

 # Further, see Net::FTP::Robust

=chapter DESCRIPTION

This module is specialized in (on the moment only) downloading large
data-sets (gigabytes) via FTP over an encrypted connection. It uses
M<Net::FTPSSL> for the encryption and M<Net::FTP::Robust> for the
logic.

=chapter METHODS

=section Constructors

=c_method new OPTIONS

Use to connect to one ftp-server.
All OPTIONS are passed to M<Net::FTPSSL> method C<new()>. These options
all start with capitals.

=option  useSSL BOOLEAN
=default useSSL <false>
When true SSL is used, otherwise TLS. This is the only M<Net::FTPSSL>
option which starts with a lower-case. Usable, but deprecated: please
use 

=option  Security SECURITY_TLS|SECURITY_SSL
=default Security SECURITY_TLS
Replaces the C<useSSL> option for M<Net::FTPSSL>.  The constants are
exported.
=cut

sub init($)
{   my ($self, $args) = @_;

    if(my $sec = delete $args->{Security})
    {   $args->{useSSL} =
            $sec eq SECURITY_TLS ? 0
          : $sec eq SECURITY_SSL ? 1
          : error "unknown security protocol {proto}", proto => $sec;
    }

    $self->SUPER::init($args);
    $self;
}

=section Download

=cut

sub _connect($)
{   my ($self, $opts) = @_;
    my $host = $opts->{Host}
        or error "no host provided to connect to";

    my $ftp = Net::FTPSSL->new($host, %$opts);
    my $err = defined $ftp ? undef : $Net::FTPSSL::ERRSTR;
    ($ftp, $err);
}

sub _modif_time($$)
{   my ($self, $ftp, $fn) = @_;
    $ftp->_mdtm($fn);
}

sub _ls($) { $_[1]->nlst }

# not implemented/not possible?
sub _can_restart($$$) { 0 }

=chapter DETAILS

=section Comparison

M<Net::FTPSSL> implements the FTP protocol over encrypted connections.
C<Net::FTPSLL::Robust> adds retries and logging, to retrieve
data which takes hours to download, sometimes over quite instable
connections.  It uses M<Log::Report> which can connect to various logging
frameworks for its messages.

=section Limitations

See L<Net::FTP::Robust/Limitations>.

=cut

1;
