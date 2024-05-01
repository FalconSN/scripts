#!/bin/bash

# chromium cookies file
cookies_file="$HOME/Cookies";
host_key="$1";

netscape_fmt="# Netscape HTTP Cookie File
"

case "$host_key" in
*[%_]*)
    where="like '$host_key'";;
*)
    where="= '$host_key'";;
esac

t=$'\t';
n=$'\n';
while read -r name value domain path httponly expiration; do
    # convert win32 epoch to unix
    (( expiration > 0 )) && {
        expiration=$(((expiration / 1000000 ) - 11644473600 ));
    }

    (( httponly == 1 )) && {
        httponly=TRUE;
    } || {
        httponly=FALSE;
    }

    netscape_fmt+="$domain${t}TRUE$t$path$t$httponly$t$expiration$t$name$t$value$n";
done < <(
sqlite3 "$cookies_file" << EOF
.mode tabs
select name,value,host_key,path,is_httponly,expires_utc
from cookies
where host_key $where
EOF
)

echo "$netscape_fmt" > "${host_key//%/}-cookie.txt"

