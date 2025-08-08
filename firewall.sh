#!/bin/bash

# Ustawienie domyślnych polityk
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Zezwolenie na lokalne połączenia
iptables -A INPUT -i lo -j ACCEPT

# Zezwolenie na SSH
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Zezwolenie na Wazuh agenta
iptables -A INPUT -p tcp --dport 1514 -j ACCEPT
iptables -A INPUT -p tcp --dport 55000 -j ACCEPT

# Zezwolenie na Elasticsearch
iptables -A INPUT -p tcp --dport 9200 -j ACCEPT

# Zezwolenie na syslog (UDP i TCP)
iptables -A INPUT -p udp --dport 514 -j ACCEPT
iptables -A INPUT -p tcp --dport 514 -j ACCEPT

# Zezwolenie na połączenia już nawiązane
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Zablokowanie wszystkiego innego
iptables -A INPUT -j DROP

