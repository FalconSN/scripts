#!/bin/bash
set -e
# Chromium Cookies file
cookies_file="$HOME/Cookies";
host_key="$1";

read -r name value domain path httponly expiration < <(
sqlite3 "$cookies_file" << EOF
.mode tabs
select name,value,host_key,path,is_httponly,expires_utc
from cookies
where host_key = "$host_key" and name = 'session'
EOF
)

# Convert win32 epoch to unix
expiration=$((($expiration/1000000)-11644473600));

(( httponly == 1 )) && {
    httponly=TRUE;
} || {
    httponly=FALSE;
}

[ ${domain:0:1} = '.' ] || {
    domain=".${domain}"
}

netscape_fmt="# Netscape HTTP Cookie File
"

for var in "$domain" "TRUE" "$path" "$httponly" \
    "$expiration" "$name" "$value"; do
    netscape_fmt+="$var"$'\t';
done

netscape_fmt+=$'\n';
echo "$netscape_fmt" > "${host_key}-cookie.txt"

