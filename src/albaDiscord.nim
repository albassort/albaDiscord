import std/paths
const
  root = $(parentDir Path(currentSourcePath))

{.compile: "./discord.c".}
{.passl: "-ldiscord -lcurl".}
{.passc: "-I" & root & "/concord/include/".} 
{.passc: "-I" & root & "/concord/core/".} 
{.passc: "-I" & root & "/concord/gencodecs/".} 

import os
import strutils
import net
import std/monotimes

type Verb* = enum
  PING = 0, IS_INIT = 1,
  SET_TOKEN = 2, SEND_MESSAGE = 3
type DiscordResult* = enum
 good, bad, dead
proc run_discord_server(port : cint) {.importc.}
proc createDiscordThread*(port : cint) {.gcsafe.} =
  echo "port"
  run_discord_server(port)

proc sendDiscordEvent(a : Socket, verb : Verb, payload = "", channel : uint64 = 0) : DiscordResult =
  let channelData = cast[array[0 .. 7, char]](channel).join("")
  a.send(channelData.join("") & char(verb) & payload)
  try:
    let data = a.recv(1, timeout = 500)
    let isGood = data[0] == '\1'
    if isGood:
      return good
    else:
      return bad
  except CatchableError as e:
    return dead
var discordMessageChannel : Channel[(string, uint64)]
discordMessageChannel.open()

proc discordMesageThread(a : (string, cint)) =

  var socket = newSocket()
  let token = a[0]
  let port = a[1]
  echo port
  var t : Thread[cint]
  createThread(t, createDiscordThread, port)

  socket.connect("127.0.0.1", Port(port))
  when not defined(offline):
    doAssert(sendDiscordEvent(socket, SET_TOKEN, token) == good)
  while (true):
    let discordMessage = discordMessageChannel.tryRecv
    if not discordMessage.dataAvailable:
      sleep 5
      continue
    let msg = discordMessage.msg
    discard sendDiscordEvent(socket, SEND_MESSAGE, msg[0], msg[1])
    sleep 5

template initDiscord*(auth : string, port : cint, t : var Thread[(string, cint)]) =
  createThread(t, discordMesageThread, (auth, port))

proc sendMessageToDiscord*(message : string, channel : uint64) =
  discordMessageChannel.send((message, channel))

when isMainModule:
  let init = ("replace me!", cint 5102)
  var t : Thread[(string, cint)]
  initDiscord(init[0], init[1], t)
  let x : uint64 = uint 1333121475640692870
  let t1 = getMonoTime()
  for y in 0 .. 4:
    sendMessageToDiscord("Dev work is now done", x)
  echo getMonoTime()-t1
  joinThread(t)
