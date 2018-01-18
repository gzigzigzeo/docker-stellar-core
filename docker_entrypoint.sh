#! /usr/bin/env bash
set -o errexit
set -o pipefail

/usr/local/bin/confd -onetime -backend env

if psql "$STELLAR_CORE_DATABASE_URL" -c "\dt" | grep "No relations" > /dev/null; then
	stellar-core --conf /etc/stellar-core.cfg --newdb --conf etc/stellar-core.cfg
fi

if [[ ! -e "$STELLAR_CORE_BASE_PATH/$STELLAR_CORE_HISTORY_CACHE_SUBPATH/.well-known/stellar-history.json" ]]; then
  echo "newhist: ok"
  stellar-core --newhist cache --conf /etc/stellar-core.cfg
fi

exec "$@"
