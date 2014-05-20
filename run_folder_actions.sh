#! /usr/bin/env bash

#############
### Usage:
###   ${ME} [-f FAILURE_ACTION] [-s SUCCES_ACTION] [-e AFTER_EACH_ACTION] -a ACTION...
###   ${ME} [-f FAILURE_ACTION] [-s SUCCES_ACTION] [-e AFTER_EACH_ACTION] -d DEFAULT_ACTION
###   ${ME} [-f FAILURE_ACTION] [-s SUCCES_ACTION] [-e AFTER_EACH_ACTION] -d DEFAULT_ACTION -a ACTION...
### 
###  Processes the contents of the current/working directory using the specified
###  actions.  Actions are specified by matching a glob pattern to an executable (
###  we'll refer to these as handlers).
###
###  e.g.
###   *.gif=/path/to/gif/handler
###
###  Since invocation requires passing a glob=path string, you'll need to pay close
###  attention to quoting or escaping the ACTION and DEFAULT_ACTION parameters.
###
###  When a glob pattern associated for a handler matches a file in the current 
###  directory, the handler will be invoked with the full path to the matching file
###  as the only parameter.
### 
###  e.g.
###   /path/to/gif/handler /current/directory/pants.gif
###
###  The steps for invocation of a handler are has follows.
###
###  - for each action glob, find any matching files in the current directory
###  - lock the matched file by creating a 'lock directory' named the same as the
###    file with an extension of .lock.
###  -- if the lock fails to be aquired, a log message will be printed and processing
###     will continue with the next match
###  - log a start indicator to standard out, indicating the handler invoked and
###    the start time of the execution of the handler
###  - with the lock aquired, invoke the handler as described above redirecting the 
###    standard output and error streams from the handler to the stdout of ${ME}
###  - log an end indicator, indicating the handler invoked and the completion time
###  - if the handler exited with a non-zero exit code invoke FAILURE_ACTION
###  - if the handler exited with an exit code of zero invoke SUCCESS_ACTION
###  - if there is an AFTER_EACH_ACTION, invoke it
###  
#############

usage() {
  echo
  egrep '^### ' ${0} | sed -e 's[^###[ [g' -e "s[\${ME}[${0}[g"
  echo
  exit 1
}
DEFAULT_ACTION=
declare -a ACTION_LIST
ACTION_INDEX=0
while getopts "ha:d:" o; do
    case "${o}" in
        a)
            ACTION=${OPTARG}
            ACTION_INDEX=$((( $ACTION_INDEX + 1 )))
            echo "ID: ${ACTION_INDEX} ${ACTION}"
            ACTION_LIST[${ACTION_INDEX}]=$ACTION
            ;;
        d)
            [ -z "${DEFAULT_ACTION}" ] || ( echo "only one default action allowed" && exit 1 )
            DEFAULT_ACTION=${OPTARG}
            ;;
        h)
            usage
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))
for index in $(seq ${#ACTION_LIST[*]})
do
  echo $index
done
