#! /usr/bin/env bash
set -o errexit
set -o pipefail

/usr/local/bin/confd -onetime -backend env

if psql "$STELLAR_CORE_DATABASE_URL" -c "\dt" | grep "No relations" > /dev/null; then
	stellar-core --conf /etc/stellar-core.cfg --newdb
	stellar-core --conf /etc/stellar-core.cfg --newhist cache
fi

exec "$@"
