#!/bin/bash
HOSTNAME=$(hostname)
HOSTIP=$(hostname -I)
NNODES=$(jq '.request.replicas' /work/JobParameters.json)
JOBID=${HOSTNAME#j-}
JOBID=${JOBID%-job-*}
CWD=$(pwd)
for RANK in $(seq 0 $((NNODES-1)))
do
    TARGET=j-${JOBID}-job-${RANK}
    LOGOUT=$CWD/$TARGET.out
    LOGERR=$CWD/$TARGET.err
    echo "Starting worker on $TARGET with sdout to $LOGOUT and stderr to $LOGERR"
    ssh -i ~/.ssh/fairy_pirate_id_rsa $TARGET "nohup /work/training/OLMo/scripts/start.sh $1 $HOSTIP > $LOGOUT 2> $LOGERR &"
    tmux new-window -n out_$RANK "tail -n +1 -f $LOGOUT"
    tmux new-window -n err_$RANK "tail -n +1 -f $LOGERR"
done
echo "Started $NNODES workers :-)"
