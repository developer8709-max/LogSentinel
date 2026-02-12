#!/bin/bash

OUTDIR="$1"
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

RULES="$BASE_DIR/config/rules.conf"

source "$RULES"

echo
echo "==== LogSentinel Incident Correlation Report ===="
echo

echo "[*] SSH Failed Login Analysis"
echo "----------------------------------"

if [ -s "$OUTDIR/ssh_failed_users.txt" ]; then
    while read -r COUNT USER; do
        if [ "$COUNT" -ge "$MAX_SSH_FAIL" ]; then
            echo "ALERT: User $USER has $COUNT failed SSH logins (possible brute-force)"
        else
            echo "INFO: User $USER has $COUNT failed SSH logins"
        fi
    done < "$OUTDIR/ssh_failed_users.txt"
else
    echo "No SSH failed login events found"
fi

echo
echo "[*] Sudo Usage Analysis"
echo "----------------------------------"

if [ -s "$OUTDIR/sudo_users.txt" ]; then
    while read -r COUNT USER; do
        if [ "$COUNT" -ge "$MAX_SUDO_COUNT" ]; then
            echo "WARN: User $USER used sudo $COUNT times"
        else
            echo "INFO: User $USER used sudo $COUNT times"
        fi
    done < "$OUTDIR/sudo_users.txt"
else
    echo "No sudo usage found"
fi

echo
echo "[*] Cross Correlation (SSH + sudo)"
echo "----------------------------------"

if [ -s "$OUTDIR/ssh_failed_users.txt" ] && [ -s "$OUTDIR/sudo_users.txt" ]; then

    awk '{print $2}' "$OUTDIR/ssh_failed_users.txt" | sort > /tmp/ls_ssh_users.tmp
    awk '{print $2}' "$OUTDIR/sudo_users.txt" | sort > /tmp/ls_sudo_users.tmp

    MATCH=$(comm -12 /tmp/ls_ssh_users.tmp /tmp/ls_sudo_users.tmp)

    if [ -n "$MATCH" ]; then
        for u in $MATCH; do
            echo "CRITICAL: User $u appears in both failed SSH logins and sudo usage"
            echo "Possible account compromise or abuse detected"
        done
    else
        echo "No correlated risky users found"
    fi

    rm -f /tmp/ls_ssh_users.tmp /tmp/ls_sudo_users.tmp
else
    echo "Not enough data for correlation"
fi

echo
echo "[*] Recent suspicious syslog entries"
echo "----------------------------------"

if [ -s "$OUTDIR/syslog_suspicious.txt" ]; then
    cat "$OUTDIR/syslog_suspicious.txt"
else
    echo "No suspicious syslog entries found"
fi
