#!/usr/bin/env bash

#shellcheck source=shell-and-scripting-helpers/.qfuncs.sh
source ~/.qfuncs.sh

set -e -o pipefail
shopt -s dotglob lastpipe

if [[ $1 =~ ^--?h(elp)?$ ]]; then
   cat - <<EOM
USAGE:
   $cmd_base [OPTION]
WTF:
   You must be in the Iosevka checked-out repository root.
   This will build TTF and WOFF2 fonts defined in your private-build-plans.toml
   and place them in dist/
OPTIONS:
   (absent options)   Build all font formats (TTF and WOFF2) hinted and unhinted
   ttf                Build TTF fonts only
   ttf-unhinted       Build TTF fonts only, unhinted
   webfont            Build WOFF2 fonts only
   webfont-unhinted   Build WOFF2 fonts only, unhinted
What does hinted/unhinted mean?
   Hinted fonts have instructions for rasterizers to improve legibility at small
   sizes. Unhinted fonts do not have these instructions, which may result in 
   better rendering on high-DPI screens or at large sizes.
EOM
   exit 1
fi

option="${1:-contents}"

find_build_plans() {
   grep -E '[buildPlans\.Iosevka[a-zA-Z0-9+]]' private-build-plans.toml |
      while read -r line; do
         if [[ $line =~ \[buildPlans\.(Iosevka[a-zA-Z0-9+]+)\] ]]; then
            echo "${BASH_REMATCH[1]}"
         fi
      done
}

# Find plans
mapfile -t plans < <(find_build_plans)

if [[ ${#plans[@]} -eq 0 ]]; then
   echo "Error: No build plans found in private-build-plans.toml" >&2
   exit 1
fi

for plan in "${plans[@]}"; do
   confirm_cmd_execute npm run build -- "${option}"::"$plan" || :
done
