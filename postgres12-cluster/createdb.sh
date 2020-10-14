  #!/bin/bash
DBNAME=$1
DBTEMPLATE=$2
DBPASS=$3

psql -U $POSTGRES_USER -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$DBTEMPLATE';"
psql -U $POSTGRES_USER -c "CREATE DATABASE $DBNAME WITH TEMPLATE = $DBTEMPLATE;"
psql -U $POSTGRES_USER -c "CREATE USER $DBNAME WITH PASSWORD '$DBPASS';"
for tbl in `psql -U $POSTGRES_USER -qAt -c "select tablename from pg_tables where schemaname = 'public';" $DBNAME` ; do  psql -U $POSTGRES_USER -c "alter table \"$tbl\" owner to $DBNAME" $DBNAME ; done
for tbl in `psql -U $POSTGRES_USER -qAt -c "select sequence_name from information_schema.sequences where sequence_schema = 'public';" $DBNAME` ; do  psql -U $POSTGRES_USER -c "alter sequence \"$tbl\" owner to $DBNAME" $DBNAME ; done
for tbl in `psql -U $POSTGRES_USER -qAt -c "select table_name from information_schema.views where table_schema = 'public';" $DBNAME` ; do  psql -U $POSTGRES_USER -c "alter view \"$tbl\" owner to $DBNAME" $DBNAME ; done

psql -U $POSTGRES_USER -d $DBNAME -t -c "GRANT ALL PRIVILEGES ON DATABASE $DBNAME TO $DBNAME; \
GRANT USAGE ON SCHEMA public TO $DBNAME; \
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $DBNAME; \
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $DBNAME; \
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO $DBNAME; \
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO $DBNAME;"

psql -U $POSTGRES_USER -t -c "CREATE ROLE read_$DBNAME; \
GRANT CONNECT ON DATABASE $DBNAME TO read_$DBNAME;"
psql -U $POSTGRES_USER -d $DBNAME -t -c "GRANT USAGE ON SCHEMA public TO read_$DBNAME; \
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_$DBNAME; \
GRANT SELECT, USAGE ON ALL SEQUENCES IN SCHEMA public TO read_$DBNAME; \
ALTER DEFAULT PRIVILEGES FOR ROLE $DBNAME IN SCHEMA public GRANT SELECT ON TABLES TO read_$DBNAME; \
ALTER DEFAULT PRIVILEGES FOR ROLE $DBNAME IN SCHEMA public GRANT SELECT, USAGE ON SEQUENCES TO read_$DBNAME;"

psql -U $POSTGRES_USER -t -c "CREATE ROLE write_$DBNAME; \
GRANT CONNECT, TEMPORARY ON DATABASE $DBNAME TO write_$DBNAME;"
psql -U $POSTGRES_USER -d $DBNAME -t -c "GRANT USAGE ON SCHEMA public TO write_$DBNAME; \
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO write_$DBNAME; \
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO write_$DBNAME; \
ALTER DEFAULT PRIVILEGES FOR ROLE $DBNAME IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO write_$DBNAME; \
ALTER DEFAULT PRIVILEGES FOR ROLE $DBNAME IN SCHEMA public GRANT ALL ON SEQUENCES TO write_$DBNAME;"

psql -U $POSTGRES_USER -t -c "CREATE ROLE admin_$DBNAME WITH INHERIT; \
GRANT CONNECT, CREATE, TEMPORARY ON DATABASE $DBNAME TO admin_$DBNAME;"
psql -U $POSTGRES_USER -d $DBNAME -t -c "GRANT USAGE ON SCHEMA public TO admin_$DBNAME; \
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO admin_$DBNAME; \
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO admin_$DBNAME; \
ALTER DEFAULT PRIVILEGES FOR ROLE $DBNAME IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO admin_$DBNAME; \
ALTER DEFAULT PRIVILEGES FOR ROLE $DBNAME IN SCHEMA public GRANT ALL ON SEQUENCES TO admin_$DBNAME; \
REVOKE CREATE ON SCHEMA public FROM public; \
GRANT CREATE ON SCHEMA public to $DBNAME; \
GRANT CREATE ON SCHEMA public to admin_$DBNAME;"
