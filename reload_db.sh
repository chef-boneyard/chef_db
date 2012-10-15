#!/bin/bash

# Check exit codes on all comamnds execute in script
# Immediatly exists if any fail; useful for debugging
#set -e
# Trace execution of all commands; useful for debugging
#set -x

USER="opscode_chef"
DB_NAME="opscode_chef"
DB_TYPE="pgsql"

usage()
{
cat << EOF
usage: $0 options

Load the schema into the database, first dropping then recreating the database.

OPTIONS:
  -h Show this message
  -u Database user
  -d Database name
  -t Databaes type (e.g. pgsql or mysql)
EOF
}

while getopts "hu:d:t:" OPTION
do
  case $OPTION in
    h)
      usage
      exit 1
      ;;
    u)
      USER=$OPTARG
      ;;
    d)
      DB_NAME=$OPTARG
      ;;
    t)
      DB_TYPE=$OPTARG
      ;;
    ?)
      usage
      exit
      ;;
  esac
done


if [ "$DB_TYPE" == "mysql" ]; then
  SCHEMA="priv/mysql_schema.sql"
  DROPDB=$(mysql -u $USER -e "DROP DATABASE $DB_NAME")
  CREATEDB=$(mysql -u $USER -e "CREATE DATABASE $DB_NAME")
  LOADSCHEMA=$(mysql -u $USER $DB_NAME < $SCHEMA)
elif [ "$DB_TYPE" == "pgsql" ]; then
  SCHEMA="priv/pgsql_schema.sql"
  DROPDB=$(dropdb -U $USER $DB_NAME)
  CREATEDB=$(createdb -U $USER -O $USER $DB_NAME)
  LOADSCHEMA=$(psql -U $USER $DB_NAME < $SCHEMA)
else
  usage
  exit
fi

echo "Using Databasename $DB_NAME"
echo "Using Username $USER"
echo "Using Schema $SCHEMA"

if [ -n "$DROPDB" ]; then
  echo "Dropped database $DB_NAME"
fi

if [ -n  "$CREATEDB" ]; then
  echo  "Created databaes $DB_NAME"
fi

if [ -n "$LOADSCHEMA" ]; then
  echo "Loaded Schema $SCHEMA"
fi
