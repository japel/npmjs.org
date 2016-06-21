#!/bin/bash

c=${npm_package_config_couch}

if [ "$c" == "" ]; then
  cat >&2 <<-ERR
Please set a valid 'npmjs.org:couch' npm config.

You can put PASSWORD in the setting somewhere to
have it prompt you for a password each time, so
it doesn't get dropped in your config file.

If you have PASSWORD in there, it'll also be read
from the PASSWORD environment variable, so you
can set it in the env and not have to enter it
each time.
ERR
  exit 1
fi

case $c in
  *PASSWORD*)
    if [ "$PASSWORD" == "" ]; then
      echo -n "Password: "
      read -s PASSWORD
    fi
    ;;
  *);;
esac

rev=$(curl -k "$c"/_design/app | json _rev)
if [ "$rev" != "" ]; then
  rev="?rev=$rev"
fi

auth="$(node -pe 'a=require("url").parse(process.argv[1]).auth;a?"-u \""+a+"\"":""' "$c")"
url="$(node -pe 'u=require("url");p=u.parse(process.argv[1]);delete p.auth;u.format(p)' "$c")"

curl -k ${auth:+-u "$auth"} "$url/_design/scratch" \
	  -X COPY \
	    -H destination:'_design/app'$rev
