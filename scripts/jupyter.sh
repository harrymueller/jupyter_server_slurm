#!/bin/bash
# alias script - some duplication of defaults
##############################
# SETUP
##############################
SCRIPT_DIR=$(dirname "$0")
LOGS=$SCRIPT_DIR/../

SHOW_HELP=false
START=false
CANCEL=false
GET_IP=false

##############################
# HELP FUNCTION
##############################
function show_help {
    echo "Start a Jupyter Server using SBATCH. Either start or cancel are required."
    echo "Usage: ./jupyter.sh [options]"
    echo "    -h, --help          Show this help message and exit"
    echo "    -s, --start         Start Jupyter server"
    echo "    --cancel            Stop Jupyter server"
    echo "    -g, --go            Default server (12h, 16CPUs, 128GB)"
    echo "    -i, --ip            Get the IP of the current server"
    echo "    -t, --time          Set time for server to run for (default: 01:00:00)"
    echo "    -c, --cpus          Number of CPUs (default: 4)"
    echo "    -m, --mem           Memory (default: 8G)"
    echo "    -p, --partition     Partition (default: regular)"
    echo "    -n, --name          Job Name (default: jupyter_server_hm)"
}

##############################
# START / CANCEL FUNCTIONS
##############################
function start {
    if [ -e "$LOGS/ip.txt" ]; then #server already started
        echo "  > Server already started."
        echo "      > IP: $(cat $LOGS/ip.txt)"
    else 
        sh $SCRIPT_DIR/start_jupyter.sh $PARAMETERS
    fi
}

function stop {
    if [ -e "$LOGS/ip.txt" ]; then #server is started
        sh $SCRIPT_DIR/stop_jupyter.sh $PARAMETERS
    else 
        echo "  > Server not started."
    fi
}

##############################
# PARSE ARGUMENTS
##############################
PARAMETERS=$@

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help) SHOW_HELP=true ;;
        -s|--start|-g|--go) START=true ;;
        --cancel) CANCEL=true ;;
        -i|--ip) GET_IP=true ;;
        -n|--name) NAME="$2"; shift ;;
    esac
    shift
done

# Show help if -h or --help was provided
if [ $SHOW_HELP = true ]; then
    show_help
    exit 0
fi

NAME=${NAME:-"jupyter_server_$USER"}

##############################
# IF NODE NOT RUNNING, DELETE LOGS
##############################
NODE=$(squeue -u $USER -n $NAME -o="%R" -h | sed 's/^=//')
if [ -z "$NODE" ]; then # node doesn't exist
    if [ -f $LOGS/$NAME.out ]; then 
        echo "  > Removing files from shutdown server..."
        rm $LOGS/$NAME.out;
    fi
    if [ -f $LOGS/ip.txt ]; then rm $LOGS/ip.txt; fi
fi

##############################
# CHECK START STOP
##############################
if [[ $GET_IP = true ]]; then
    if [ -f $LOGS/ip.txt ]; then
        echo "  > IP is $(cat $LOGS/ip.txt)"
    else
        echo "  > No Jupyter server is started"
    fi
else
    if [[ $START = true ]] && [[ $CANCEL = true ]]; then
        stop; start
    elif [[ $START = true ]]; then
        start
    elif [[ $CANCEL = true ]]; then
        stop
    else
        echo "  > Server must either be started or stop"
    fi
fi