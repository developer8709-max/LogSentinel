#!/bin/bash

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

REPORT_DIR="$BASE_DIR/reports"
TMP_DIR="/tmp/logsentinel"

mkdir -p "$REPORT_DIR" "$TMP_DIR"

TIMESTAMP=$(date +"%Y%m%d%H%M%S")
REPORT_FILE="$REPORT_DIR/incident-report-$TIMESTAMP.txt"

echo "LogSentinel – Linux Log Correlation Framework" > "$REPORT_FILE"
echo "Created by Murari Singh" >> "$REPORT_FILE"
echo "Generated at: $(date)" >> "$REPORT_FILE"
echo "--------------------------------------------" >> "$REPORT_FILE"

bash "$BASE_DIR/parsers/auth_parser.sh" "$TMP_DIR"
bash "$BASE_DIR/parsers/syslog_parser.sh" "$TMP_DIR"
bash "$BASE_DIR/engine/correlate.sh" "$TMP_DIR" >> "$REPORT_FILE"

echo
echo "[+] Report created:"
echo "$REPORT_FILE"
