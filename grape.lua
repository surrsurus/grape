local tape = require("component").tape_drive
local arg = {...}

-- Seek to byte n on a cassette
function seek(n)
  tape.seek(n)
end

-- Smart tape drive monitor - run as threaded event
function monitor()

  -- while true do
  if tape.isEnd() then
    seek(-tape.getPosition())
  end
  if tape.getState() == "REWINDING" then    
    seek(-tape.getPosition())
  end
  -- os.execute("sleep " .. tonumber(0.5))

end

if arg[1] == ("s" or "seek") then
  
  local n =  tonumber(arg[2])

  if type(n) ~= "number" then
    print("Err: arg 2 must be num")
    do return false end
  end

  seek(n)
  
  do return true end

elseif arg[1] == ("r" or "rewind") then

  seek(-tape.getPosition())
  
  do return true end

elseif arg[1] == ("c" or "copy") then
  print("proceed with caution! is fucky wucky!")
  
  local addr_a = arg[2]
  local addr_b = arg[3]
  
  local drives = {}

  local tape_a = require("component").proxy(addr_a)
  local tape_b = require("component").proxy(addr_b)
  
  print("copying " .. tape_a.getLabel() .. " to " .. tape_b.getLabel())
  print("ok?")
  io.read()
  
  tape_a.seek(-tape_a.getPosition())
  tape_b.seek(-tape_b.getPosition())

  local t = 0

  while t < tape_a.getSize() do
    tape_b.write(tape_a.read(10000))
    tape_a.seek(10000)
    tape_b.seek(10000)
  end 

  do return true end

elseif arg[1] == ("m" or "monitor") then
  
  print("monitor running.")
   
  -- Runs as thread
  local event = require("event")
  -- Make this 1 if you want more CPU
  event.timer(0.5, monitor, math.huge)

else
  print("grape <command>")
  print("(s)eek <n>     -  seek n bytes. n can be negative. can be done while tape is playing")
  print("(r)ewind       - instantly rewind a tape")
  print("(m)onitor      - start monitor mode. in monitor mode, any connected tape drive will automatically insta-rewind on rewind press and at tape end.")
  print("(c)opy <a> <b> - it does things, mostly bad, will brick something. if you value your pc you dont run this.")
  do return false end
end
