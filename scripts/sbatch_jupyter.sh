#!/bin/bash
#SBATCH --ntasks=1

##############################
# START JUPYTER
##############################
source ~/.bashrc

# setupping up micromamba
module load micromamba
micromamba activate $JUPYTER_ENV

jupyter lab --no-browser --ip='*' --port=8080