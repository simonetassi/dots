#!/bin/bash

if [ "$(makoctl mode)" == "do-not-disturb" ]; then
    icon=""
else
    icon=""
fi

echo "{\"text\": \"$icon\", \"tooltip\": \"Toggle DND on/off\"}"
