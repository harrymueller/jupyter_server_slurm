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
    echo "Stop a Jupyter Server using SCANCEL with the given name."
    echo "Usage: ./stop_jupyter.sh [options]"
    echo "    -h, --help          Show this help message and exit"
    echo "    -n, --name          Job Name (default: jupyter_server_hm)"
}

##############################
# PARSE ARGUMENTS
##############################
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help) SHOW_HELP=true; shift ;; 
        -s|--start) ;;
        --cancel) ;;
        -n|--name) NAME="$2"; shift ;;
    esac
    shift
done

# Show help if -h or --help was provided
if [ $SHOW_HELP = true ]; then
    show_help
    exit 0
fi

NAME=${NAME:-"jupyter_server_hm"}

##############################
# START SBATCH
##############################
scancel -u $USER -n $NAME

# empty log files
if [ -f $LOGS/$NAME.out ]; then rm $LOGS/$NAME.out; fi 
if [ -f $LOGS/ip.txt ]; then rm $LOGS/ip.txt; fi

echo "  > Stopped Jupyter Server"