time_started=$(date +%s)
echo "time_started = $time_started"

mco puppet runonce -I openbus-nn1
mco rpc -S "puppet().lastrun>=${time_started}" -I openbus-nn1 puppet last_run_summary

