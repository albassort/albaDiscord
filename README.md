# albaDiscord

This is a very simple and lightweight tool to send messages to discord. An absolute minimal amount of the discord api is exposed through this library; in fact, the only features it has is: send messages.

It used in a bigger project, to provide live discord notifications in replacement for SMTP.  

# Dependencies 

- Libcurl
- Concord (provided via git module in the repository itself)
- A C compiler (depends on concord thus cannot compile via NLVM or similar toolchains)

# Usage

```nim
import albaDiscord
# Key for your discord bot
let key = "discord key"
# Port to communicate with the discord helper over UDP
let port = cint 5012
# A thread to spawn the discord helper
var t : Thread[(string, cint)]
# Inits the helper, its now bound to t
initDiscord(key, port, t)
# The channel you wish to send the message to
let channel : uint64 = uint 1333121475640692870

let t1 = getMonoTime()
for y in 0 .. 4:
  sendMessageToDiscord("Hello, from Nim!", channel)
echo getMonoTime()-t1
```
```
```


# Testing
Testing is implemented using `podman`, and can be configured via the following bash command:
```sh
$: git config core.hooksPath .githooks
```

This enables the pre-commit script defined in .githooks/pre-commit, and it will run the script defined in ./podman-test.sh internally within the container. It does the following

1. Adds the necessary dependencies (curl-dev, make, git)
2. Copy the current albaDiscord directroy
3. Attempt to install albaDiscord
4. Attempt to import and compile albaDiscord in nim

This is to prevent regression in potential future releases.
