version       = "0.0.0"
author        = "Caroline Marceano [Albassort]"
description   = "A minimal discord api for sending messages to channels."
license       = "MIT"
srcDir        = "./src"
requires "nim >= 2.0.6"

after install:
  let pkgDir = getCurrentDir()  
  exec "mkdir -p  " & pkgDir & "/concord/lib"
  exec "make -C " & pkgDir & "/concord"
