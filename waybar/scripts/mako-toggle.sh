#!/bin/bash

# Toggle DND
	if [ "$(makoctl mode)" == "do-not-disturb" ]; then
	# DND OFF
		makoctl mode -r do-not-disturb && echo "" 
	else
	# DND ON
		makoctl mode -s do-not-disturb && echo ""
	fi
