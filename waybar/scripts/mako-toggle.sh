#!/bin/bash

if [ "$(makoctl mode)" == "do-not-disturb" ]; then
    makoctl mode -r do-not-disturb >/dev/null
else
    makoctl mode -s do-not-disturb >/dev/null
fi
