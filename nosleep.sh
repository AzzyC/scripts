#!/bin/bash

restore () {
  powercfg -setactive "$activescheme" 2> /dev/null
  powercfg -delete "$newscheme" 2> /dev/null
}
trap restore SIGINT

activescheme="$(powercfg -getactivescheme | awk '{print $4}')"
newscheme="$(powercfg -duplicatescheme "$activescheme" | awk '{print $4}')"

powercfg -changename "$newscheme" "No Sleep"
powercfg -setactive "$newscheme"

powercfg -change monitor-timeout-ac 0
powercfg -change monitor-timeout-dc 0
powercfg -change disk-timeout-ac 0
powercfg -change disk-timeout-dc 0
powercfg -change standby-timeout-ac 0
powercfg -change standby-timeout-dc 0
powercfg -change hibernate-timeout-ac 0
powercfg -change hibernate-timeout-dc 0

"$@"

restore
