#!/bin/bash

OUTDIR="$1"
AUTH_LOG=""

if [ -f /var/log/auth.log ]; then
    AUTH_LOG="/var/log/auth.log"
elif [ -f /var/log/secure ]; then
    AUTH_LOG="/var/log/secure"
else
    echo "No auth log found" > "$OUTDIR/auth_events.txt"
    exit 0
fi

# Failed ssh logins
grep -i "Failed password" "$AUTH_LOG" \
| awk '{print $(NF-3)}' \
| sort | uniq -c | sort -nr \
> "$OUTDIR/ssh_failed_users.txt"

# sudo usage
grep -i "sudo" "$AUTH_LOG" \
| grep -i "COMMAND" \
| awk '{print $(NF-5)}' \
| sort | uniq -c | sort -nr \
> "$OUTDIR/sudo_users.txt"
