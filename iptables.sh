#!/bin/sh
PATH=/sbin:/bin:/usr/bin:/usr/sbin

# update kernel module
depmod -a

# load kernel module
modprobe ipt_LOG
modprobe ipt_MASQUERADE
modprobe ip_conntrack_ftp
modprobe ip_nat_ftp
modprobe ipt_limit
modprobe ipt_REJECT
modprobe ipt_state

# define IP for each NIC
WAN_IP="xxx.xxx.xxx.xxx"
LAN_IP="yyy.yyy.yyy.yyy"
DMZ_IP="zzz.zzz.zzz.zzz"
LO_IP="127.0.0.1"

# define device_name for each NIC
WAN_IF="ethx"
LAN_IF="ethy"
DMZ_IF="ethz"
LO_IF="lo"

# define Broadcast LAN Side
LAN_BCAST="ttt.ttt.ttt.ttt"

# define IP for each server on DMZ
HTTP_DMZ="aaa.aaa.aaa.aaa"
MAIL_DMZ="bbb.bbb.bbb.bbb"
FTP_DMZ="ccc.ccc.ccc.ccc"

# define IP for each server on LAN
SSH_LAN="ddd.ddd.ddd.ddd"
HTTP_LAN="eee.eee.eee.eee"

# initialize policy
iptables -F
iptables -Z
iptables - P INPUT DROP
iptables - P OUTPUT DROP
iptables - P FORWARD DROP

# Create User-defined Base Chain
iptables -N ACCEPT_CONN
iptables -A ACCEPT_CONN -p TCP --syn -j ACCEPT
iptables -A ACCEPT_CONN -p TCP -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A ACCEPT_CONN -p TCP -j DROP

# Create User-defined PING receive chain
iptables -N ICMP_PACKET
iptables -A ICMP_PACKET -p icmp -s 0/0 --icmp-type 3 -j ACCEPT
iptables -A ICMP_PACKET -p icmp -s 0/0 --icmp-type 8 -j ACCEPT
iptables -A ICMP_PACKET -p icmp -s 0/0 --icmp-type 11 -j ACCEPT


