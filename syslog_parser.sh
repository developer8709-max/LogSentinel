#!/bin/bash

OUTDIR="$1"
SYSLOG=""

if [ -f /var/log/syslog ]; then
    SYSLOG="/var/log/syslog"
else
    echo "No syslog found" > "$OUTDIR/syslog_events.txt"
    exit 0
fi

grep -i -E "error|fail|critical" "$SYSLOG" \
| tail -n 50 \
> "$OUTDIR/syslog_suspicious.txt"
