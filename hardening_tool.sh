#!/bin/bash

# ==============================================================================
# Title:        Automated Linux Hardening & Audit Tool
# Description:  Audits and hardens Linux endpoints against security risks.
# Author:       [Kameswara Surya Yashmit Akundi]
# ==============================================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

SSH_CFG="/etc/ssh/sshd_config"

if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[-] Error: This script must be run as root.${NC}"
  exit 1
fi

echo -e "${GREEN}[+] Root privileges verified. Starting Security Tool...${NC}\n"

# ------------------------------------------------------------------------------
# AUDIT FUNCTIONS
# ------------------------------------------------------------------------------

audit_ssh() {
    echo -e "${YELLOW}[*] Auditing SSH Configuration...${NC}"

    if [ -f "$SSH_CFG" ]; then
        if grep -qE "^\s*PermitRootLogin\s+yes" "$SSH_CFG"; then
            echo -e "${RED}[-] CRITICAL RISK: 'PermitRootLogin' is set to 'yes' in $SSH_CFG!${NC}"
            echo -n "Would you like to automatically harden this SSH setting? (y/n): "
            read user_choice
            
            case "$user_choice" in
                [yY][eE][sS]|[yY])
                    harden_ssh
                    ;;
                *)
                    echo -e "${YELLOW}[!] Warning: Remediation skipped.${NC}"
                    ;;
            esac
        else
            echo -e "${GREEN}[+] SECURE: 'PermitRootLogin' is safely disabled or restricted.${NC}"
        fi
    else
        echo -e "${YELLOW}[!] Warning: SSH file not found.${NC}"
    fi
}

audit_firewall() {
    echo -e "\n${YELLOW}[*] Auditing Network Firewall...${NC}"
    
    if ufw status | grep -q "Status: active"; then
        echo -e "${GREEN}[+] SECURE: UFW Firewall is active and monitoring traffic.${NC}"
    else
        echo -e "${RED}[-] CRITICAL RISK: UFW Firewall is DISABLED!${NC}"
        echo -n "Would you like to automatically enable the firewall? (y/n): "
        read fw_choice
        
        case "$fw_choice" in
            [yY][eE][sS]|[yY])
                harden_firewall
                ;;
            *)
                echo -e "${YELLOW}[!] Warning: Firewall remains disabled.${NC}"
                ;;
        esac
    fi
}

# ------------------------------------------------------------------------------
# HARDENING FUNCTIONS
# ------------------------------------------------------------------------------

harden_ssh() {
    echo -e "${YELLOW}[*] Applying SSH Hardening remediation...${NC}"
    cp "$SSH_CFG" "${SSH_CFG}.bak"
    sed -i 's/^\s*PermitRootLogin\s+yes/PermitRootLogin no/g' "$SSH_CFG"
    systemctl restart ssh
    echo -e "${GREEN}[+] SUCCESS: SSH config modified. 'PermitRootLogin' is now 'no'.${NC}"
}

harden_firewall() {
    echo -e "${YELLOW}[*] Enabling UFW Firewall...${NC}"
    ufw allow ssh > /dev/null
    ufw --force enable
    echo -e "${GREEN}[+] SUCCESS: UFW firewall has been enabled and configured with basic rules.${NC}"
}

# ------------------------------------------------------------------------------
# MAIN EXECUTION FLOW
# ------------------------------------------------------------------------------
main() {
    audit_ssh
    audit_firewall
    echo -e "\n${GREEN}[+] Execution complete!${NC}"
}

main
