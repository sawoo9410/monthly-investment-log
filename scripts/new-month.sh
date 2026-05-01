#!/usr/bin/env bash
# 사용법: ./scripts/new-month.sh YYYY-MM
# 예: ./scripts/new-month.sh 2026-05

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 YYYY-MM" >&2
  exit 1
fi

YM="$1"

if ! [[ "$YM" =~ ^[0-9]{4}-(0[1-9]|1[0-2])$ ]]; then
  echo "Error: invalid format. Expected YYYY-MM (e.g. 2026-05)" >&2
  exit 1
fi

YEAR="${YM%%-*}"
MONTH="${YM##*-}"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET_DIR="$REPO_ROOT/$YEAR/$YM"
TEMPLATE_DIR="$REPO_ROOT/TEMPLATE"

if [ -d "$TARGET_DIR" ]; then
  echo "Error: $TARGET_DIR already exists" >&2
  exit 1
fi

# 직전 달 계산 (저번 달 투자 근황 비교용)
if [ "$MONTH" = "01" ]; then
  PREV_YEAR=$((10#$YEAR - 1))
  PREV_MONTH="12"
else
  PREV_YEAR="$YEAR"
  PREV_MONTH=$(printf "%02d" $((10#$MONTH - 1)))
fi
PREV_YM="${PREV_YEAR}-${PREV_MONTH}"

mkdir -p "$TARGET_DIR"

for f in summary.md transactions.md holdings.md; do
  sed -e "s/{{YYYY-MM}}/$YM/g" -e "s/{{PREV_YYYY-MM}}/$PREV_YM/g" \
    "$TEMPLATE_DIR/$f" > "$TARGET_DIR/$f"
done

echo "Created: $TARGET_DIR"
ls -1 "$TARGET_DIR"
