#!/bin/bash

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

powercfg -setactive "$activescheme"
powercfg -delete "$newscheme"
