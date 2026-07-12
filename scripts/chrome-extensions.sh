#!/usr/bin/env bash
# Öffnet die Chrome-Web-Store-Seiten der empfohlenen Extensions in Tabs.
# WICHTIG: Auf einem privaten (nicht-MDM) Mac erlaubt Chrome KEINE stille
# Installation. Also je Tab einmal "Zu Chrome hinzufügen" klicken.
# Danach in Chrome anmelden -> Sync spielt sie automatisch auf den iMac.
#
# Nutzung:  ./chrome-extensions.sh          (Kern-Set)
#           ./chrome-extensions.sh --dev    (zusätzlich Dev-Extensions)
set -e
store="https://chromewebstore.google.com/search"

echo "▸ Kern-Extensions…"
open -a "Google Chrome" "$store/Vimium"
open -a "Google Chrome" "$store/uBlock%20Origin%20Lite"
open -a "Google Chrome" "$store/Dark%20Reader"
open -a "Google Chrome" "$store/Privacy%20Badger"
open -a "Google Chrome" "$store/ClearURLs"

if [ "${1:-}" = "--dev" ]; then
  echo "▸ Dev-Extensions…"
  open -a "Google Chrome" "$store/React%20Developer%20Tools"
  open -a "Google Chrome" "$store/Vue.js%20devtools"
  open -a "Google Chrome" "$store/JSON%20Viewer"
  open -a "Google Chrome" "$store/Wappalyzer"
fi
echo "Tabs geöffnet — je Extension einmal 'Hinzufügen'."
echo "Hinweis: Lighthouse, Responsive-Modus, Farb-Picker sind in den DevTools schon eingebaut."
