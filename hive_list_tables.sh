#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2019-12-06 11:10:26 +0000 (Fri, 06 Dec 2019)
#
#  https://github.com/harisekhon/bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#

# List Hive tables in all databases via beeline
#
# Tested on Hive 1.1.0 on CDH 5.10, 5.16

# For Hive 3.0+ information schema is finally available which is more efficient than iterating per database eg.
#
# SELECT * FROM information_schema.tables
# (table_catalog, table_schema, table_name)

# For Hive < 3.0 - consider using adjacent impala_list_tables.sh instead as it is much faster

# Hive doesn't suffer from db authz issue listing metadata like Impala, which gets:
#
# ERROR: AuthorizationException: User '<user>@<domain>' does not have privileges to access: default   Default Hive database.*.*
#
set -eu -o pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(dirname "$0")"

opts="--silent=true --outputformat=tsv2"

# shellcheck disable=SC2086
"$srcdir/hive_list_databases.sh" "$@" |
while read -r db; do
    "$srcdir/beeline.sh" $opts -e "SHOW TABLES FROM \`$db\`" "$@" |
    tail -n +2 |
    sed "s/^/$db	/"
done
