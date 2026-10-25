#!/usr/bin/env bash
# Builds the combined blocklists in dist/ from the per-brand files in lists/.
set -euo pipefail
cd "$(dirname "$0")"

domains() { grep -hvE '^\s*(#|$)' "$@" | tr -d '\r' | awk '{print tolower($1)}' | sort -u; }

core=(lists/lg.txt lists/samsung.txt lists/roku.txt)
mkdir -p dist

{ echo "# Smart TV ad blocklist (hosts format) — Pi-hole, AdGuard Home, router hosts files"
  domains "${core[@]}" | sed 's/^/0.0.0.0 /'; } > dist/smart-tv-hosts.txt

{ echo "! Smart TV ad blocklist (adblock format, blocks subdomains too) — AdGuard Home, Pi-hole v6+"
  domains "${core[@]}" | sed 's/^/||/; s/$/^/'; } > dist/smart-tv-adguard.txt

{ echo "! OPTIONAL aggressive Smart TV list — read lists/optional-aggressive.txt first"
  domains lists/optional-aggressive.txt | sed 's/^/||/; s/$/^/'; } > dist/smart-tv-aggressive-adguard.txt

{ echo "! Smart TV allowlist — keeps Roku working"
  domains lists/allowlist.txt | sed 's/^/@@||/; s/$/^/'; } > dist/smart-tv-allowlist-adguard.txt

wc -l dist/*.txt
