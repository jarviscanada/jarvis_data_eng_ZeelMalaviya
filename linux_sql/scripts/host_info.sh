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

# Save the output of lscpu to a variable
lscpu_out=$(lscpu)

# Extract the number of CPUs
cpu_number=$(echo "$lscpu_out" | grep "^CPU(s):" | awk '{print $2}' | xargs)

# Extract the CPU architecture
cpu_architecture=$(echo "$lscpu_out" | grep "^Architecture:" | awk '{print $2}' | xargs)

# Extract the CPU model
cpu_model=$(echo "$lscpu_out" | grep "Model name:" | awk -F: '{print $2}' | xargs)

# Extract the CPU MHz
cpu_mhz=$(echo "$lscpu_out" | grep "CPU MHz:" | awk -F: '{print $2}' | xargs)
# Provide a default value if cpu_mhz is empty
if [ -z "$cpu_mhz" ]; then
    cpu_mhz="0"
fi

# Extract the L2 cache size or provide a default value
l2_cache=$(echo "$lscpu_out" | grep "L2 cache:" | awk -F: '{print $2}' | xargs | sed 's/[^0-9]//g')
if [ -z "$l2_cache" ]; then
    l2_cache="0"
fi

# Extract total memory in KB
total_mem=$(grep MemTotal /proc/meminfo | awk '{print $2}' | xargs)

# Save current timestamp
timestamp=$(date '+%Y-%m-%d %H:%M:%S')

# Check if the host already exists
host_id=$(psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -t -c "SELECT id FROM host_info WHERE hostname='$hostname'" | xargs)

if [ -z "$host_id" ]; then
    # Host does not exist, insert a new record
    insert_stmt="INSERT INTO host_info (hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, total_mem, timestamp) VALUES ('$hostname', '$cpu_number', '$cpu_architecture', '$cpu_model', '$cpu_mhz', '$l2_cache', '$total_mem', '$timestamp')"
else
    # Host exists, update the existing record
    insert_stmt="UPDATE host_info SET cpu_number='$cpu_number', cpu_architecture='$cpu_architecture', cpu_model='$cpu_model', cpu_mhz='$cpu_mhz', l2_cache='$l2_cache', total_mem='$total_mem', timestamp='$timestamp' WHERE hostname='$hostname'"
fi

# Set up environment variable for psql command
export PGPASSWORD=$psql_password

# Execute the insert/update statement through psql CLI tool
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"

# Retrieve the host_id for the inserted or updated record
host_id=$(psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -t -c "SELECT id FROM host_info WHERE hostname='$hostname'" | xargs)

echo "Host information inserted/updated with ID: $host_id"
exit $?

