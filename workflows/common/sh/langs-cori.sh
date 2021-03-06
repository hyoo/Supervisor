
# LANGS CORI
# Language settings for Cori (Python, R, etc.)
# Assumes WORKFLOWS_ROOT is set
# Assumes modules are loaded (cf. modules-cori.sh)

# Python
COMMON_DIR=$WORKFLOWS_ROOT/common/python
export PYTHONPATH=${PYTHONPATH:-}${PYTHONPATH:+:}
PYTHONPATH+=$EMEWS_PROJECT_ROOT/python:
PYTHONPATH+=$BENCHMARK_DIR:
PYTHONPATH+=$COMMON_DIR
export PYTHONHOME=/global/common/cori/software/python/2.7-anaconda/envs/deeplearning

# R
export R_HOME=/global/u1/w/wozniak/Public/sfw/R-3.4.0/lib64/R

# Swift/T
export PATH=/global/homes/w/wozniak/Public/sfw/compute/swift-t-r/stc/bin:$PATH

# LD_LIBRARY_PATH
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}${LD_LIBRARY_PATH:+:}
LD_LIBRARY_PATH+=$R_HOME/lib

# Log settings to output
which python swift-t
# Cf. utils.sh
show     PYTHONHOME
log_path LD_LIBRARY_PATH
log_path PYTHONPATH

