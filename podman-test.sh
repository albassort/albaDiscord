#!/bin/bash
apk add curl-dev
apk add git
apk add make
cd /root/albaDiscord
nimble install
echo "import albaDiscord" >test.nim
nim c test
