# 🔐 SSH-Logger

Postet bei **SSH-Logins** eine Discord-Nachricht (Embed) mit:
- Server-Name, Server-IP, User-IP, User
- Server-OS, Login-Zeit
- **Uptime**, **Load Avg (1|5|15)**
- **Failed SSH Logins (last 5m)**
- Geolocation (City/Region/Country) & ISP

---

## ✨ Features

- 🌍 **Geo/ISP** – ein Request an ipinfo
- 🕒 **Systeminfos** – OS, Uptime, Loadavg, fehlgeschlagene SSH-Logins (5 Min.)
- 🧱 **Sonstiges** – Coming soon

---

## 📦 Installation (Copy & Paste)

### 1) System aktualisieren
```bash
sudo apt update && sudo apt upgrade -y
```

### 2) Script einfügen & Webhook anpassen
```bash
sudo nano /opt/ssh_loggerV1.sh
```

### 3) Berechtigung erteilen
```bash
sudo chmod +x /opt/ssh_loggerV1.sh
```

### 4) Profile anpassen
```bash
sudo nano etc/profile
#an letzter Stelle einfügen: /opt/ssh_loggerV1.sh
```

