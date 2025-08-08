# 📬 Konfiguracja Postfix jako klient SMTP relay

Ten poradnik pokazuje, jak skonfigurować **Postfix** do wysyłania poczty przez zewnętrzny serwer SMTP (relay).  
Przydatne jako szybka ściąga.

---

## 1️⃣ Instalacja Postfix

```bash
sudo apt update
sudo apt install postfix mailutils
```

Podczas instalacji wybierz **Internet Site**.

> 💡 **Uwaga:** Jeżeli przez pomyłkę wybrałeś *System rozproszony* zamiast *Internet Site*, możesz później zmienić konfigurację poleceniem:
> ```bash
> sudo dpkg-reconfigure postfix
> ```
> i wybrać poprawną opcję.

---

## 2️⃣ Podstawowa konfiguracja Postfix

Otwórz główny plik konfiguracyjny:

```bash
sudo nano /etc/postfix/main.cf
```

Dodaj lub zmodyfikuj poniższe linie (zastąp `smtp.twojserwer.pl` swoim serwerem SMTP):

```ini
relayhost = [smtp.twojserwer.pl]:587
smtp_use_tls = yes
smtp_sasl_auth_enable = yes
smtp_sasl_security_options = noanonymous
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt
```

> ℹ️ **Porty SMTP:**
> - `587` – SMTP z TLS (zalecany)  
> - `465` – SMTP z SSL  
> - `25` – zwykły SMTP (często blokowany przez dostawców)

---

## 3️⃣ Ustaw dane logowania do serwera SMTP

Utwórz plik z loginem i hasłem:

```bash
sudo nano /etc/postfix/sasl_passwd
```

Dodaj:

```txt
[smtp.twojserwer.pl]:587 login@domena.pl:TwojeHaslo
```

---

## 4️⃣ Zabezpieczenie pliku i generowanie mapy

```bash
sudo chmod 600 /etc/postfix/sasl_passwd
sudo postmap /etc/postfix/sasl_passwd
```

---

## 5️⃣ Restart Postfix

```bash
sudo systemctl restart postfix
```

---

## 6️⃣ Test wysyłki wiadomości

```bash
echo "Testowa wiadomość" | mail -s "Test SMTP Postfix" twojmail@adres.pl
```

---

## 7️⃣ Sprawdzanie kolejki i logów

Jeżeli mail nie dochodzi:

```bash
mailq
sudo tail -n 50 /var/log/mail.log
```

W logach znajdziesz informacje o błędach (np. zły login, port, problem z TLS).

---

## 8️⃣ (Opcjonalnie) Ustawienie nadawcy na stały adres

Dodaj do `main.cf`:

```ini
sender_canonical_maps = hash:/etc/postfix/sender_canonical
```

Utwórz plik:

```bash
sudo nano /etc/postfix/sender_canonical
```

Przykład zawartości:

```txt
root@localhost login@domena.pl
```

Potem:

```bash
sudo postmap /etc/postfix/sender_canonical
sudo systemctl restart postfix
```

---

## 9️⃣ (Opcjonalnie) Konfiguracja SSL/TLS na porcie 465

Jeżeli serwer wymaga połączenia SSL:

W `main.cf`:

```ini
relayhost = [smtp.twojserwer.pl]:465
smtp_use_tls = yes
smtp_tls_wrappermode = yes
```

W `sasl_passwd`:

```txt
[smtp.twojserwer.pl]:465 login@domena.pl:TwojeHaslo
```

---

## 🔟 (Opcjonalnie) Czyszczenie kolejki

Aby usunąć wszystkie maile z kolejki:

```bash
sudo postsuper -d ALL
```

---

✅ **Gotowe!** Postfix jest skonfigurowany do wysyłania poczty przez wybrany serwer SMTP.
