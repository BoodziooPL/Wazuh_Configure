# Konfiguracja Wazuh + Postfix (SMTP Relay) + Firewall

Ten poradnik zawiera:
- Konfigurację Postfix jako klienta SMTP relay (np. `smtp.dpanel.pl`)
- Konfigurację Wazuh Dashboard z HTTPS
- Skrypt `iptables` dla zabezpieczenia serwera
- Instrukcję zapisywania reguł firewalla na stałe

---

## 1. Konfiguracja Postfix

### Instalacja Postfix
```bash
sudo apt update
sudo apt install postfix mailutils -y
```

Podczas konfiguracji wybierz:
- **Internet Site** lub **Satellite system** (w przypadku SMTP relay)
- **System mail name**: `mojadomena.pl`

---

### Ustawienia `/etc/postfix/main.cf`
Dodaj lub zmień:

```conf
relayhost = [smtp.dpanel.pl]:587
smtp_use_tls = yes
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_sasl_security_options = noanonymous
smtp_tls_security_level = encrypt
smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt
```

---

### Plik `/etc/postfix/sasl_passwd`
```text
[smtp.dpanel.pl]:587 security@mojadomena.pl:mojehaslo
```

Zabezpieczenie i kompilacja:
```bash
sudo chmod 600 /etc/postfix/sasl_passwd
sudo postmap /etc/postfix/sasl_passwd
sudo systemctl restart postfix
```

---

### Test wysyłki maila
```bash
echo "Test Wazuh mail" | mail -s "Powiadomienie" user@twojadomena.pl
```

---

## 2. Konfiguracja Wazuh Dashboard (HTTPS na porcie 443)

Edytuj `/etc/wazuh-dashboard/opensearch_dashboards.yml`:

```yaml
server.host: 0.0.0.0
server.port: 443
server.ssl.enabled: true
server.ssl.key: "/etc/wazuh-dashboard/certs/wazuh-dashboard-key.pem"
server.ssl.certificate: "/etc/wazuh-dashboard/certs/wazuh-dashboard.pem"
opensearch.hosts: https://127.0.0.1:9200
opensearch.ssl.certificateAuthorities: ["/etc/wazuh-dashboard/certs/root-ca.pem"]
opensearch.ssl.verificationMode: certificate
opensearch_security.multitenancy.enabled: false
uiSettings.overrides.defaultRoute: /app/wz-home
```

Restart:
```bash
sudo systemctl restart wazuh-dashboard
```

---

## 3. Konfiguracja Firewalla (iptables)

### Skrypt `firewall.sh`
```bash
#!/bin/bash
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 1514 -j ACCEPT
iptables -A INPUT -p tcp --dport 1515 -j ACCEPT
iptables -A INPUT -p tcp --dport 55000 -j ACCEPT
iptables -A INPUT -p tcp --dport 9200 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p udp --dport 514 -j ACCEPT
iptables -A INPUT -p tcp --dport 514 -j ACCEPT
iptables -A INPUT -p tcp --dport 25 -j ACCEPT
iptables -A INPUT -p tcp --dport 587 -j ACCEPT
iptables -A INPUT -j DROP
```

Zapisywanie pliku:
```bash
nano ~/firewall.sh
chmod +x ~/firewall.sh
```

Uruchomienie:
```bash
sudo ~/firewall.sh
```

---

### Zapisywanie reguł po restarcie
```bash
sudo apt install iptables-persistent -y
sudo netfilter-persistent save
sudo netfilter-persistent reload
```

---

## 4. Testy działania

1. **Dashboard**: `https://IP_SERVERA`
2. **SSH**: `ssh user@IP_SERVERA`
3. **Wysyłka maila**:
```bash
echo "Test" | mail -s "Powiadomienie Wazuh" user@twojadomena.pl
```
4. **Firewall**:
```bash
sudo iptables -L -n -v
```

---

✅ Gotowe – serwer jest zabezpieczony, Wazuh działa na 443, Postfix wysyła powiadomienia przez SMTP relay.
