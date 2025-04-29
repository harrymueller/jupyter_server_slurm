# jupyter_server_slurm
Shell scripts for running jupyter server with SLURM

Requires micromamba environment with jupyter installed, and path to folder in environment variable `JUPYTER_ENV`

## Setting up jupyter server
1. Start jupyter server `start_jupyter.sh`
2. Figure out node: `squeue -u $USER`
3. Get token from `err.out`, add node as IP
4. Connect to SL in VS Code
5. Choose juypter kernel
    1. Existing jupyter server
    2. Paste in URL

### Files
1. `jupyter.sh`: Overarching file for starting, stopping, getting IP etc.
2. `start_jupyter.sh`: Starting jupyter server
3. `stop_jupyter.sh`: Stop jupyter server
4. `sbatch_jupyter.sh`: Batch command
