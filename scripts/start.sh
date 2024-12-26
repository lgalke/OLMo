#!/bin/bash
HOSTNAME=$(hostname)
NNODES=$(jq '.request.replicas' /work/JobParameters.json)
GPUS=$(jq '.request.product.id' /work/JobParameters.json)
GPUS=${GPUS##*-}
GPUS=${GPUS%\"}
JOBID=${HOSTNAME#j-}
JOBID=${JOBID%-job-*}
RANK=${HOSTNAME##*-}
ENDPOINT=$2
OLMO_SHARED_FS=1
echo "HOSTNAME=$HOSTNAME, NNODES=$NNODES, GPUS=$GPUS, JOBID=$JOBID, RANK=$RANK, ENDPOINT=$ENDPOINT, OLMO_SHARED_FS=$OLMO_SHARED_FS"
. ~/miniconda3/etc/profile.d/conda.sh
conda activate olmo
conda info
cd /work/training/OLMo/
pwd
torchrun --nnodes=$NNODES --nproc_per_node=$GPUS --rdzv-id=$JOBID --rdzv-backend=c10d --rdzv-endpoint=$ENDPOINT --node_rank=$RANK scripts/train.py $1 --save_overwrite
echo "=== DONE OUT ==="
echo "=== DONE ERR ===" >&2
