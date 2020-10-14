#!/bin/bash

# exit 1 at slave
if [ "$(psql -U $POSTGRES_USER -d $POSTGRES_DB -At -c \
    'select pg_is_in_recovery();')" = "f" ]; then
    exit 0
else
    exit 1
fi
