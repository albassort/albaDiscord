# albaDiscord

This is a very simple and lightweight tool to send messages to discord. An absolute minimal amount of the discord api is exposed through this library; in fact, the only features it has is: send messages.

It used in a bigger project, to provide live discord notifications in replacement for SMTP.  

# Dependencies 

- Libcurl
- Concord (provided via git module in the repository itself)
- A C compiler (depends on concord thus cannot compile via NLVM or similar toolchains)

# Usage

```nim
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
