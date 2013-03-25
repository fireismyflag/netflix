Netflix World-Wide
=======

A script, and a set of configuration files to assist in overriding
netflix authentication to allow for out of country access.

This setup uses the following tools, which should be installed on
a server based in the USA (for US Netflix).

- bind (named)
- squid
- perl

I am in no way affiliated with Netflix.
This code and configuration is provided as is, with no warranty.

What you need to do before use:

1)

Modify the firewall file, replacing %%YOUR_IP_HERE%% with your IP,
This restricts access to your new service to only your IP.

2)

Move firewall to /etc/init.d/ and install as a service,
In this case, I use CentOS, so to do this, run the following command:

chkconfig --add firewall
chkconfig firewall on

Start the firewall:

service firewall start

3)

Create a self signed SSL certificate for squid, and update squid.conf with the new locations if they have changed.
Modify squid.conf, replace %%YOUR_SERVER_HOSTNAME_HERE%% with the hostname of your new server,
place squid.conf in /etc/squid/ (location is dependant on your distribution).

4)

Place named.conf in /etc/ (again, location dependant on distro)

5)

Modify dns.pl, replace %%YOUR_SERVER_IP_HERE%% with the IP address of your new server

6)

Run dns.pl, this will instantly daemonize and run in the background

7)

Start bind/named

8)

Start Squid

9)

Check to ensure that things are working properly, on your local system send a DNS request to your new server,
on linux/mac this would be something like:

dig netflix.com @%%YOUR_SERVER_IP_HERE%%

this should return the IP address of your server,

All DNS not served by dns.pl (IE: normal internet traffic), is forwarded to opendns's resolvers, however
you can change these to what ever you wish!
