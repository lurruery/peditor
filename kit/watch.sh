#!/usr/bin/env zsh

coffee='node_modules/.bin/coffee'
stylus='node_modules/.bin/stylus'

# Compile coffeescripts.
$coffee -o client/js/ -wcb client/lib/ &
$coffee -wcb client/widgets/ &

# Compile stylus.
if [ ! -d client/css/ ]; then
	mkdir client/css/
fi
$stylus -o client/css/ -w client/styles/ &
$stylus -w client/widgets/*
