# 📘 Must-Have Wazuh Hardening & NIS2 Compliance Guide

## 1. Założenia NIS2
Z punktu widzenia NIS2, Wazuh ma realizować:
- **Monitorowanie integralności** (syscheck) – realtime dla krytycznych plików.
- **Wykrywanie rootkitów** (rootcheck) – często, np. co godzinę.
- **Audyt konfiguracji** (SCA) – zgodność z CIS, ale nie spam do e-mail.
- **Bezpieczną komunikację z agentami** – TLS + uwierzytelnianie.
- **Centralne logowanie i analiza** – retention min. 180 dni.
- **Alerting krytycznych incydentów** – wysyłka e-mail/SIEM.

---

## 2. Konfiguracja na serwerze Wazuh (`/var/ossec/etc/ossec.conf`)

### **A. Globalne ustawienia i alerting**
```xml
<alerts>
  <log_alert_level>3</log_alert_level>
  <email_alert_level>10</email_alert_level>
</alerts>
```

### **B. Bezpieczna komunikacja z agentami**
```xml
<auth>
  <disabled>no</disabled>
  <port>1515</port>
  <use_source_ip>yes</use_source_ip>
  <purge>yes</purge>
  <use_password>yes</use_password>
  <ssl_agent_ca>/etc/ossec/ssl/agent-ca.pem</ssl_agent_ca>
  <ssl_verify_host>yes</ssl_verify_host>
  <ssl_manager_cert>/etc/ossec/ssl/manager-cert.pem</ssl_manager_cert>
  <ssl_manager_key>/etc/ossec/ssl/manager-key.pem</ssl_manager_key>
</auth>

<remote>
  <connection>secure</connection>
  <port>1514</port>
  <protocol>tcp</protocol>
  <allowed-ips>LISTA_IP_AGENTÓW</allowed-ips>
</remote>
```

### **C. Rootcheck – co godzinę**
```xml
<rootcheck>
  <disabled>no</disabled>
  <frequency>3600</frequency>
  <check_files>yes</check_files>
  <check_trojans>yes</check_trojans>
  <check_dev>yes</check_dev>
  <check_sys>yes</check_sys>
  <check_pids>yes</check_pids>
  <check_ports>yes</check_ports>
  <check_if>yes</check_if>
  <skip_nfs>yes</skip_nfs>
  <ignore>/var/lib/docker/overlay2</ignore>
  <ignore>/var/log</ignore>
</rootcheck>
```

### **D. Syscheck – monitoring integralności**
```xml
<syscheck>
  <disabled>no</disabled>
  <scan_on_start>yes</scan_on_start>
  <frequency>21600</frequency>
  <directories realtime="yes">/etc</directories>
  <directories>/usr/bin</directories>
  <directories>/usr/sbin</directories>
  <directories>/bin</directories>
  <directories>/sbin</directories>
  <directories>/boot</directories>
  <alert_new_files>yes</alert_new_files>
  <ignore>/var/log</ignore>
  <ignore>/tmp</ignore>
  <ignore type="sregex">.log$|.tmp$</ignore>
</syscheck>
```

### **E. SCA – audyt konfiguracji**
```xml
<sca>
  <enabled>yes</enabled>
  <scan_on_start>yes</scan_on_start>
  <interval>12h</interval>
  <skip_nfs>yes</skip_nfs>
</sca>
```

### **F. Vulnerability Detection**
```xml
<vulnerability-detection>
  <enabled>yes</enabled>
  <index-status>yes</index-status>
  <feed-update-interval>60m</feed-update-interval>
</vulnerability-detection>
```

---

## 3. Konfiguracja agentów Windows (`ossec.conf` po stronie agenta)

### **A. Połączenie z serwerem**
```xml
<client>
  <server>
    <address>IP_SERWERA_WAZUH</address>
    <port>1514</port>
    <protocol>tcp</protocol>
  </server>
  <config-profile>windows</config-profile>
</client>
```

### **B. Syscheck – realtime pliki + monitoring rejestru**
```xml
<syscheck>
  <disabled>no</disabled>
  <frequency>21600</frequency>
  <directories realtime="yes">C:\Windows\System32\drivers\etc</directories>
  <directories realtime="yes">C:\Windows\System32\config</directories>
  <directories realtime="yes">C:\Program Files</directories>
  <alert_new_files>yes</alert_new_files>

  <windows_registry realtime="yes">HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run</windows_registry>
  <windows_registry realtime="yes">HKEY_LOCAL_MACHINE\Security</windows_registry>
</syscheck>
```

### **C. Rootcheck na Windows**
```xml
<rootcheck>
  <disabled>no</disabled>
  <frequency>3600</frequency>
</rootcheck>
```

---

## 4. Po wdrożeniu – testy

**Rootcheck test**  
Linux:
```bash
sudo touch /dev/.libroot
sudo systemctl restart wazuh-manager
```

Windows:
Utwórz plik w monitorowanym katalogu.

**Syscheck test**  
- Edytuj `/etc/hosts` (Linux) lub `C:\Windows\System32\drivers\etc\hosts` (Windows).
- Sprawdź alert w dashboardzie.

**SCA test**  
- Wyłącz regułę CIS (np. brak hasła root).
- Sprawdź dashboard.

---

## 5. Retencja logów
- Elasticsearch/Indexera: ustaw ILM policy min. 180 dni.

---

## 6. Checklist po instalacji
✅ TLS + uwierzytelnianie agentów  
✅ Rootcheck co 1h  
✅ Syscheck realtime dla krytycznych plików  
✅ Audyt CIS (SCA) – dashboard only  
✅ Alerty krytyczne na e-mail  
✅ ILM 180 dni
