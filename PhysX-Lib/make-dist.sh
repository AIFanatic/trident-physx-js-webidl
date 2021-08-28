#!/bin/bash

mkdir ../dist

./make-production.sh
./make-debug.sh

# Fix js file for the web
node ./post-dist.js