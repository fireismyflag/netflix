#!/usr/bin/perl

use strict;
use warnings;
use Proc::Daemon;
Proc::Daemon::Init;
my $continue = 1;
$SIG{TERM} = sub { exit };
use Net::DNS::Nameserver;
use Net::DNS::Resolver;
our $opendns = Net::DNS::Resolver->new(
	nameservers	=> [qw(208.67.222.222 208.67.220.220)],
	recurse		=> 1,
	debug		=> 0,
);
our %proxied;
$proxied{'netflix.com'}=1;
$proxied{'www.netflix.com'}=1;
$proxied{'moviecontrol.netflix.com'}=1;
$proxied{'movies.netflix.com'}=1;
$proxied{'cbp-us.nccp.netflix.com'}=1;
$proxied{'api-global.netflix.com'}=1;
$proxied{'app.boxee.tv'}=1;
$proxied{'boxee-proxy.appspot.com'}=1;

sub reply_handler {
	my ($qname, $qclass, $qtype, $peerhost,$query,$conn) = @_;
	my ($rcode, @ans, @auth, @add, $authoritive, $type, $rr, $packet);
	if (defined($proxied{$qname})) {
		$type="proxied";
	} else {
		$type="opendns";
	}
        if (!$qclass) {
                $qclass="IN";
        }
        if ($type eq "proxied") {
                if ($qtype eq "A") {
                        $rr=new Net::DNS::RR(
                                name    => "$qname",
                                ttl     => 300,
                                class   => 'IN',
                                type    => 'A',
                                address => '%%YOUR_SERVER_IP_HERE%%'
                        );
                        push @ans, $rr;
                        $rcode="NOERROR";
                } else {
                        $rcode="NXDOMAIN";
                }
                $authoritive=1;
        } else {
                $packet=$opendns->query("$qname","$qtype","$qclass");
                if (!$packet) {
                        $rcode="NXDOMAIN";
                } else {
                        foreach my $rec ($packet->answer) {
                                push @ans, $rec;
                        }
                        $rcode="NOERROR";
                }
                $authoritive=0;
        }
	return ($rcode, \@ans, \@auth, \@add, { aa => $authoritive });
}

my $ns = new Net::DNS::Nameserver(
	LocalPort=> "5353",
	LocalAddr=> "127.0.0.1",
	ReplyHandler => \&reply_handler,
	Verbose	 => 0
	) || die "couldn't create nameserver object\n";

$ns->main_loop;
