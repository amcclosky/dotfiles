#!/bin/bash

if [ -f /usr/local/bin/virtualenvwrapper.sh ]; then 
    source /usr/local/bin/virtualenvwrapper.sh
fi

if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi
