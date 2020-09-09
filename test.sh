#!/usr/bin/env bash

_DIR=$(dirname $(realpath "$0"))
cd $_DIR

tape test/**/*.coffee|npx colortape
