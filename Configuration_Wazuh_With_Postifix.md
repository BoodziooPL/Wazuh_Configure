# Konfiguracja Wazuh + Postfix (SMTP Relay przez smtp.server.pl)

Ten poradnik opisuje kompletną konfigurację **Postfix** tak, aby Wazuh mógł wysyłać powiadomienia e-mail,
a Postfix przekazywał je dalej przez serwer SMTP `smtp.server.pl` z uwierzytelnieniem i TLS.

---

## 1. Instalacja Postfix
```bash
sudo apt update
sudo apt install postfix mailutils ca-certificates
```

Podczas instalacji wybierz:

- **General type of mail configuration**: `Internet Site`
- **System mail name**: `twojadomena.pl` (np. `mojadomena.pl`)
- **Root and postmaster mail recipient**: Twój e-mail (np. `admin@twojadomena.pl`)
- **Local networks**: zostaw domyślne (`127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128`)
- **Mailbox size limit**: `0`
- **Local address extension character**: `+`
- **Internet protocols**: `ipv4`

> Jeśli wybrałeś wcześniej `System rozproszony`, uruchom:
> ```bash
> sudo dpkg-reconfigure postfix
> ```
> i zmień na `Internet Site`.

---

## 2. Konfiguracja relayhost (smtp.server.pl)
Edytuj plik `/etc/postfix/main.cf` i upewnij się, że masz poniższe wpisy:

```ini
# Główna konfiguracja
relayhost = [smtp.server.pl]:587

# Uwierzytelnianie SMTP
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_sasl_security_options = noanonymous
smtp_sasl_tls_security_options = noanonymous

# TLS
smtp_use_tls = yes
smtp_tls_security_level = encrypt
smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt
```

---

## 3. Uwierzytelnienie (login i hasło)
Utwórz plik `/etc/postfix/sasl_passwd`:

```bash
[smtp.server.pl]:587 user@twojadomena.pl:TwojeHasloSMTP
```

Nadaj odpowiednie uprawnienia i utwórz mapę hash:
```bash
sudo chmod 600 /etc/postfix/sasl_passwd
sudo postmap /etc/postfix/sasl_passwd
```

---

## 4. Załaduj nową konfigurację
```bash
sudo systemctl restart postfix
sudo systemctl enable postfix
```

---

## 5. Test wysyłki
```bash
echo "Test Wazuh -> Postfix -> smtp.server.pl" | mail -s "Test e-mail" twojemail@domena.pl
```

Sprawdź logi, jeśli e-mail nie dotrze:
```bash
sudo tail -f /var/log/mail.log
```

---

## 6. Podłączenie Wazuh do Postfixa
W pliku konfiguracyjnym Wazuh (`/var/ossec/etc/ossec.conf`) ustaw:
```xml
<global>
  <smtp_server>localhost</smtp_server>
  <email_from>wazuh@twojadomena.pl</email_from>
  <email_to>twojemail@domena.pl</email_to>
  <email_maxperhour>12</email_maxperhour>
</global>
```

Wazuh będzie wysyłał maile na `localhost:25`, a Postfix przekieruje je do `smtp.server.pl`.

---

## 7. Sprawdzenie certyfikatu smtp.server.pl (opcjonalnie)
Aby upewnić się, że certyfikat jest podpisany przez zaufane CA:
```bash
echo | openssl s_client -connect smtp.server.pl:587 -starttls smtp 2>/dev/null | openssl x509 -noout -issuer -subject
```

Jeżeli w polu **issuer** jest np. "Let's Encrypt" lub inny znany CA, to jest on w `/etc/ssl/certs/ca-certificates.crt`.

---

## 8. Uwagi końcowe
- Plik `smtp_tls_CAfile` nie jest zawsze wymagany, ale warto go ustawić, by mieć pewność, że Postfix wie, gdzie szukać certyfikatów CA.
- Po każdej zmianie w `main.cf` wykonuj:
```bash
sudo systemctl reload postfix
```
