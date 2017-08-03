
# SH UTILS
# Misc. Bash shell functionality

show()
# Report variable names with their values
{
  for v in $*
  do
    eval echo $v=\$$v
  done
}

log_path()
# Pretty print a colon-separated variable
{
  echo ${1}:
  eval echo \$$1 | tr : '\n' | nl
}

get_site()
# Get site name (Titan, Theta, Cori, etc.)
{
  if (( ${#} < 1 ))
  then
    script_name=$(basename $0)
    echo << EOF
Usage: ${script_name} SITE EXPERIMENT_ID"
where SITE is the computer name (titan, theta, cori) and
      EXPERIMENT_ID will be the new directory under experiments
EOF
    exit 1
  fi
  export SITE=$1
}

get_expid()
# Get Experiment IDentifier
# EXPID is the name of the new directory under experiments/
# If the user provides -a, this function will autogenerate
#   a new EXPID under the experiments directory,
#   which will be exported as TURBINE_OUTPUT
{
  if [ "${#}" -ne 1 ]; then
    script_name=$(basename $0)
    echo << EOF
Usage: ${script_name} EXPERIMENT_ID"
where EXPERIMENT_ID will be the new directory under experiments
EOF
    exit 1
  fi

  EXPERIMENTS=$EMEWS_PROJECT_ROOT/experiments

  export EXPID=$1
  if [ $EXPID = "-a" ]
  then
    local i=0
    while (( 1 ))
    do
      EXPID=$( printf "X%03i" $i )
      if [[ -d $EXPERIMENTS/$EXPID ]]
      then
        i=$(( i + i*RANDOM/32767 + 1 ))
      else
        break
      fi
    done
    shift
  fi
  export TURBINE_OUTPUT=$EXPERIMENTS/$EXPID
  check_directory_exists
}

source_site()
# Source a settings file for a specific SITE (titan, cori, theta)
# Succeeds with warning message if file is not found
{
  if (( ${#} != 2 ))
  then
    echo "usage: source_site TOKEN SITE"
    echo "where TOKEN is langs, modules, etc."
    echo "  and SITE is titan, cori, theta, etc."
    return 1
  fi

  TOKEN=$1
  SITE=$2

  if [[ ${WORKFLOWS_ROOT:-} == "" ]]
  then
    echo "Set WORKFLOWS_ROOT!"
    return 1
  fi

  FILE=$WORKFLOWS_ROOT/common/sh/$TOKEN-$SITE.sh
  if ! [[ -f $FILE ]]
  then
    echo "warning: no file: $FILE"
    return 0
  fi

  source $FILE
}

queue_wait()
# Wait for given JOBID using queue tools for given SITE
{
  if (( ${#} != 2 ))
  then
    echo "usage: queue_wait SITE JOBID"
    echo " where SITE is titan, cori, theta, etc."
    echo " and   JOBID is the job number"
    return 1
  fi

  SITE=$1
  JOBID=$2

  if [[ $SITE == "cori" ]]
  then
    queue_wait_slurm $JOBID
  else
    echo "queue_wait(): unknown site: $SITE"
    return 1
  fi
}

queue_wait_slurm()
{
  if (( ${#} != 1 ))
  then
    echo "usage: queue_wait JOBID"
    return 1
  fi

  JOBID=$1

  local DELAY=30
  local DELAY_MAX=60

  while (( 1 ))
  do
    date "+%Y/%m/%d %H:%M:%S"
    if ! ( squeue | grep $JOBID )
    then
      break
    fi
    sleep $DELAY
    (( ++ DELAY ))
    if (( DELAY > DELAY_MAX ))
    then
      DELAY=$DELAY_MAX
    fi
  done
}

check_output()
{
  if (( ${#} != 5 ))
  then
    echo "usage: check_output TOKEN OUTPUT WORKFLOW SCRIPT JOBID"
    return 1
  fi

  TOKEN=$1
  OUTPUT=$2
  WORKFLOW=$3
  SCRIPT=$4
  JOBID=$5

  if grep "$TOKEN" $OUTPUT > /dev/null
  then
    # Success!
    return 0
  fi

  # Else, report error message
  echo "Could not find '$TOKEN'"
  show OUTPUT WORKFLOW SCRIPT JOBID
  return 1
}
