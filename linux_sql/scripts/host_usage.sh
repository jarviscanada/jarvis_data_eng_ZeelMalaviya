#!/bin/bash

# Assign CLI arguments to variables
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

# Check number of arguments
if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

# Save hostname as a variable
hostname=$(hostname -f)

# Save machine statistics in MB
vmstat_mb=$(vmstat --unit M)

# Extract free memory in MB
memory_free=$(echo "$vmstat_mb" | tail -n 1 | awk '{print $4}' | xargs)

# Extract CPU idle percentage
cpu_idle=$(echo "$vmstat_mb" | tail -n 1 | awk '{print $15}' | xargs)

# Extract CPU kernel percentage
cpu_kernel=$(echo "$vmstat_mb" | tail -n 1 | awk '{print $14}' | xargs)

# Extract disk I/O
disk_io=$(vmstat -d | tail -n 1 | awk '{print $10}' | xargs)

# Extract available disk space in MB
disk_available=$(df -BM / | tail -n 1 | awk '{print $4}' | sed 's/M//' | xargs)

# Save current timestamp
timestamp=$(date '+%Y-%m-%d %H:%M:%S')

# Subquery to find matching id in host_info table
host_id="(SELECT id FROM host_info WHERE hostname='$hostname')"

# Construct INSERT statement
insert_stmt="INSERT INTO host_usage(timestamp, host_id, memory_free, cpu_idle, cpu_kernel, disk_io, disk_available) VALUES ('$timestamp', $host_id, '$memory_free', '$cpu_idle', '$cpu_kernel', '$disk_io', '$disk_available')"

# Set up environment variable for psql command
export PGPASSWORD=$psql_password

# Execute INSERT statement through psql CLI tool
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"

exit $?

