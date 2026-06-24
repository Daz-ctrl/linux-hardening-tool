# Automated Linux Hardening & Audit Tool

## 📌 Project Overview
This project is a lightweight, host-based **Security Auditing and Automated Remediation Engine** written in Bash. It programmatically scans Linux endpoints for critical security misconfigurations based on enterprise hardening standards (such as CIS Benchmarks) and offers interactive, automated remediation to instantly secure vulnerabilities.

Demonstrated skills include **Linux System Administration, Endpoint Security Automation, Shell Scripting (Bash), and Network Defense Configuration.**

## ⚙️ Core Architecture & Flow
The script executes in a modular flow, handling separate security domains independently:

1. **Privilege Escalation Check:** Validates effective user ID (EUID) to ensure administrative `root` permissions are present.
2. **Configuration Auditing:** Utilizes regex parsing (`grep`, `awk`) to read deep system files without altering them.
3. **Interactive Remediation:** Prompts system administrators conditionally if a high-severity vulnerability is caught.
4. **Automated Hardening:** Programmatically modifies system parameters safely via stream editors (`sed`) and triggers native system service managers (`systemctl`).

---

## 🛠️ Security Policies Checked & Remediated

### 1. SSH Remote Access Security
* **Vulnerability Target:** Weak remote configuration allowing direct password authentication into the administrative `root` account (`PermitRootLogin yes`).
* **Risk Factor:** Leaves the endpoint highly vulnerable to remote brute-force and credential-stuffing attacks.
* **Remediation:** Backs up the active configuration file (`.bak`) and uses `sed` stream editing to strictly change the target policy to `PermitRootLogin no`, followed by an automated `ssh` daemon restart.

### 2. Network Traffic Control (Host Firewall)
* **Vulnerability Target:** Disabled network firewall (`ufw`).
* **Risk Factor:** Exposes all unmonitored local ports to the network layer, bypassing access controls.
* **Remediation:** Restructures system rules to explicitly allow incoming SSH connections (preventing admin lockout) and forces the immediate enablement of the `ufw` firewall matrix.

---

## 🚀 How To Run & Test

### Prerequisites
Tested on Debian/Ubuntu-based distributions (e.g., Linux Mint, Ubuntu Desktop/Server). Ensure OpenSSH is installed:
```bash
sudo apt update && sudo apt install openssh-server -y
