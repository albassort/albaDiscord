#!/bin/bash
apk add curl-dev
apk add git
apk add make
nimble install https://github.com/albassort/albaDiscord/
echo "import albaDiscord" >test.nim
nim c test
