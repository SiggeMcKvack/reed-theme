#!/bin/sh
# Run after upgrading FreshRSS: reports upstream changes Reed has to follow.
# Usage: tools/check-upstream.sh [container] [freshrss-root-in-container]
set -u
container=${1:-freshrss}
root=${2:-/app/www}
cd "$(dirname "$0")/.." || exit 1
status=0
up() { docker exec "$container" sh -c "cd $root && $1"; }

echo "FreshRSS $(up "grep -o \"FRESHRSS_VERSION = '[^']*'\" constants.php | cut -d\"'\" -f2")"

# Every UI icon (FreshRSS_Themes::alt) needs a Reed copy and a swap rule for background-loaded panels.
# The logo and app icon only appear in the header, never in those panels
for name in $(up "sed -n \"s/^\t\t\t'\([^']*\)' =>.*/\1/p\" app/Models/Themes.php"); do
	case $name in FreshRSS-logo|icon) continue ;; esac
	up "test -f p/themes/icons/$name.svg" || continue
	[ -f "icons/$name.svg" ] || { echo "icon missing from icons/: $name.svg"; status=1; }
	grep -q "/themes/icons/$name.svg\"" reed.css || { echo "icon has no swap rule: $name.svg"; status=1; }
done

# Base colour variables Reed doesn't set fall back to light-theme defaults (layout vars are fine)
for var in $(up "grep -oE -- '--frss-[a-z0-9-]+:' p/themes/base-theme/frss.css" | sort -u | tr -d :); do
	case $var in --frss-padding-*) continue ;; esac
	grep -q -- "$var:" reed.css || { echo "variable not set: $var"; status=1; }
done

# Markup Reed's layout depends on
for name in titleAuthorSummaryDate websiteName table-wrapper bigMarkAsRead bigTick jumpNext \
	mark-read-menu read_all form-advanced-title configure-feeds btn-subscription btn-add \
	manage-list ext_name stream-footer-inner new-article nav_entries tree-folder-title; do
	up "grep -rqF -- '$name' app/views app/layout app/Models p/scripts" || { echo "markup gone: $name"; status=1; }
done

rtl=$(mktemp)
npx --yes rtlcss@4.3.0 --silent reed.css "$rtl" >/dev/null
cmp -s "$rtl" reed.rtl.css || { echo "reed.rtl.css is stale: npx rtlcss@4.3.0 reed.css reed.rtl.css"; status=1; }
rm -f "$rtl"

[ $status -eq 0 ] && echo "OK"
exit $status
