#!/bin/bash

##############################
# SETUP
##############################
SCRIPT_DIR=$(dirname "$0")
LOGS=$SCRIPT_DIR/../

SHOW_HELP=false

##############################
# HELP FUNCTION
##############################
function show_help {
    echo "Start a Jupyter Server using SBATCH."
    echo "Usage: ./start_jupyter.sh [options]"
    echo "    -h, --help          Show this help message and exit"
    echo "    -t, --time          Set time for server to run for (default: 01:00:00) - Formats: HH:MM:SS, HH:MM, HHhMMm, HHh"
    echo "    -c, --cpus          Number of CPUs (default: 4)"
    echo "    -m, --mem           Memory (default: 8G)"
    echo "    -p, --partition     Partition (default: regular)"
    echo "    -n, --name          Job Name (default: jupyter_server_hm)"
    echo "    -g, --go            Default server (12h, 16CPUs, 512B)"
}

##############################
# TIME CONVERSION FUNCTION
##############################
# Function to convert time format
convert_time() {
    if [[ $TIME =~ ^[0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; then
        # If the format is already HH:MM:SS, do nothing
        TIME=$TIME
    elif [[ $TIME =~ ^[0-9]{2}:[0-9]{2}$ ]]; then
        # If the format is HH:MM, append :00 for seconds
       TIME=${TIME}:00
    else
        # Initialize hours and minutes to zero
        hours=0
        minutes=0

        # Extract hours and minutes from TIME
        if [[ $TIME =~ ([0-9]+)h ]]; then
            hours=${BASH_REMATCH[1]}
        fi
        if [[ $TIME =~ ([0-9]+)m ]]; then
            minutes=${BASH_REMATCH[1]}
        fi

        # Format hours and minutes as two digits and set seconds to 00
        TIME=$(printf "%02d:%02d:00" "$hours" "$minutes")
    fi
}

##############################
# PARSE ARGUMENTS
##############################
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help) SHOW_HELP=true; shift ;; 
        -t|--time) TIME="$2"; shift ;;
        -c|--cpus) CPUS="$2"; shift ;;
        -m|--mem) MEM="$2"; shift ;;
        -p|--partition) PARTITION="$2"; shift ;;
        -n|--name) NAME="$2"; shift ;;
        -s|--start) ;;
        -g|--go) TIME="12h"; CPUS="16"; MEM="256G" ;;
        --cancel) ;;
    esac
    shift
done

# Show help if -h or --help was provided
if [ $SHOW_HELP = true ]; then
    show_help
    exit 0
fi

TIME=${TIME:-"01:00:00"}
CPUS=${CPUS:-"4"}
MEM=${MEM:-"8G"}
PARTITION=${PARTITION:-"regular"}
NAME=${NAME:-"jupyter_server_$USER"}

convert_time

##############################
# START SBATCH
##############################
# empty log file, then create a new one
if [ -f $LOGS/$NAME.out ]; then rm $LOGS/$NAME.out; fi
touch $LOGS/$NAME.out

sbatch --time=$TIME --cpus-per-task=$CPUS --partition=$PARTITION --mem=$MEM \
    --job-name=$NAME --output=$LOGS/$NAME.out \
    $SCRIPT_DIR/sbatch_jupyter.sh

##############################
# GET IP
##############################
# need to wait till more than 1 line
echo "  > Waiting for jupyter to start..."
while [ $(wc -l < "$LOGS/$NAME.out") -le 20 ]; do
    sleep 0.5  # Wait for 1/2 second before checking again
done

TOKEN=$(cat $LOGS/$NAME.out | grep -oP '(?<=token=)[a-f0-9]+' | head -n 1)
NODE=$(squeue -u $USER -n $NAME -o="%R" -h | sed 's/^=//')
IP="http://$NODE:8080/lab?token=$TOKEN"

echo "  > IP is: $IP"
echo $IP > $LOGS/ip.txt