#!/bin/sh
# team-memory idle extract-facts hook
# Fires /extract-facts after IDLE_SECS idle + COOLDOWN_SECS per-session cooldown.
# Scoped via PPID so multiple concurrent sessions never interfere.
SPID="${PPID:-0}"
IDLE_SECS=120       # 2 minutes idle before firing
COOLDOWN_SECS=600   # 10 minutes between fires per session

TS=$(date +%s)
TMPBASE="${TMPDIR:-/tmp}"
ACTIVITY="$TMPBASE/tm-activity-$SPID"
SESSION_FLAG="$TMPBASE/tm-extracted-ppid-$SPID"
LOGFILE="${TEAM_MEMORY_DIR:-$HOME/.team-memory}/idle.txt"

echo $TS > "$ACTIVITY"
echo "[team-memory] $(date '+%H:%M:%S') [$SPID] hook started, waiting ${IDLE_SECS}s..." >> "$LOGFILE"
sleep $IDLE_SECS

CURRENT=$(cat "$ACTIVITY" 2>/dev/null)
LAST=$(cat "$SESSION_FLAG" 2>/dev/null || echo 0)
NOW=$(date +%s)
ELAPSED=$((NOW - LAST))

if [ "$CURRENT" = "$TS" ] && [ $ELAPSED -ge $COOLDOWN_SECS ]; then
  echo "[team-memory] $(date '+%H:%M:%S') [$SPID] idle ${IDLE_SECS}s + cooldown elapsed — firing extract-facts" >> "$LOGFILE"
  echo $NOW > "$SESSION_FLAG"
  exit 2
else
  echo "[team-memory] $(date '+%H:%M:%S') [$SPID] skipping (active or cooldown active, elapsed=${ELAPSED}s)" >> "$LOGFILE"
fi
exit 0
