#!/bin/bash
while :
do
	echo "Converting and saving file"
	openssl base64 -in /Users/saurabh.datta/Documents/Processing/sketches/tinderBot_101/infoImage.jpg -out /Users/saurabh.datta/Documents/Processing/sketches/tinderBot_101/encodedB64.txt
	echo "Done"
	sleep 10
	echo "opening base64 encoded file"
	sleep 10
	value=$(</Users/saurabh.datta/Documents/Processing/sketches/tinderBot_101/encodedB64.txt)
    echo "$value"
    sleep 10
done

