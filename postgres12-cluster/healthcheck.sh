#!/bin/bash

if select="$(echo 'SELECT 1' | psql -t -U $POSTGRES_USER)" && [ "$select" = "        1" ]; then
    exit 0
else
    exit 1
fi
