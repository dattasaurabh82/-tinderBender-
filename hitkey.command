#!/bin/sh
# Simulates hitting a key on OS X
# http://apple.stackexchange.com/a/63899/72339
while :
do
    sleep 40
	echo "tell application \"System Events\" to keystroke \"s\"" | osascript
	sleep 40
	echo "tell application \"System Events\" to keystroke \"b\"" | osascript
done

