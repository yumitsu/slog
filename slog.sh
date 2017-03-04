#!/bin/sh
#--------------------------------------------------------------------------------------------------
# log4sh - Makes logging in POSIX shell scripting suck less
# Copyright (c) Fred Palmer
# POSIX version Copyright Joe Cooper
# Licensed under the MIT license
# http://github.com/swelljoe/log4sh
#--------------------------------------------------------------------------------------------------
set -e  # Fail on first error

# Define $LOG_PATH in your script to log to a file, otherwise
# just writes to STDOUT.

# Useful global variables that users may wish to reference
SCRIPT_ARGS="$@"
SCRIPT_NAME="$0"
SCRIPT_NAME="${SCRIPT_NAME#\./}"
SCRIPT_NAME="${SCRIPT_NAME##/*/}"
SCRIPT_BASE_DIR="$(cd "$( dirname "$0")" && pwd )"

# Determines if we print colors or not
if [ $(tty -s) ]; then
	readonly INTERACTIVE_MODE="off"
else
	readonly INTERACTIVE_MODE="on"
fi

#--------------------------------------------------------------------------------------------------
# Begin Logging Section
if [ "${INTERACTIVE_MODE}" = "off" ]
then
    # Then we don't care about log colors
    readonly LOG_DEFAULT_COLOR=""
    readonly LOG_ERROR_COLOR=""
    readonly LOG_INFO_COLOR=""
    readonly LOG_SUCCESS_COLOR=""
    readonly LOG_WARN_COLOR=""
    readonly LOG_DEBUG_COLOR=""
else
    readonly LOG_DEFAULT_COLOR=$(tput sgr0)
    readonly LOG_ERROR_COLOR=$(tput setaf 1)
    readonly LOG_INFO_COLOR=$(tput sgr 0)
    readonly LOG_SUCCESS_COLOR=$(tput setaf 2)
    readonly LOG_WARN_COLOR=$(tput setaf 3)
    readonly LOG_DEBUG_COLOR="\033[1;34m"
fi

# This function scrubs the output of any control characters used in colorized output
# It's designed to be piped through with text that needs scrubbing.  The scrubbed
# text will come out the other side!
prepare_log_for_nonterminal() {
    # Essentially this strips all the control characters for log colors
    sed "s/[[:cntrl:]]\[[0-9;]*m//g"
}

log() {
    local log_text="$1"
    local log_level="$2"
    local log_color="$3"

    # Default level to "info"
    [ -z ${log_level} ] && log_level="INFO";
    [ -z ${log_color} ] && log_color="${LOG_INFO_COLOR}";

    # STDOUT
    printf "${log_color}[$(date +"%Y-%m-%d %H:%M:%S %Z")] [${log_level}] ${log_text} ${LOG_DEFAULT_COLOR}\n";
    # LOG_PATH minus fancypants colors
    if [ ! -z $LOG_PATH ]; then
        printf "[$(date +"%Y-%m-%d %H:%M:%S %Z")] [${log_level}] ${log_text}\n" >> $LOG_PATH;
    fi

    return 0;
}

log_info()      { log "$@"; }
log_success()   { log "$1" "SUCCESS" "${LOG_SUCCESS_COLOR}"; }
log_error()     { log "$1" "ERROR" "${LOG_ERROR_COLOR}"; }
log_warning()   { log "$1" "WARNING" "${LOG_WARN_COLOR}"; }
log_debug()     { log "$1" "DEBUG" "${LOG_DEBUG_COLOR}"; }

# End Logging Section
#--------------------------------------------------------------------------------------------------
