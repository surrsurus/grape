local tape = require("component").tape_drive
local arg = {...}
local REW = -10000000000000
function seek(n)
  tape.seek(n)
end

-- if not tape.isReady() then
--  print("tape not ready.")
--  do return false end
-- end

function monitor()

  -- while true do
  if tape.isEnd() then
    seek(REW)
  end
  if tape.getState() == "REWINDING" then    
    seek(REW)
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

  seek(REW)
  
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
  
  tape_a.seek(REW)
  tape_b.seek(REW)

  local t = 0

  while t < tape_a.getSize() do
    tape_b.write(tape_a.read(10000))
    tape_a.seek(10000)
    tape_b.seek(10000)
  end 

  do return true end

elseif arg[1] == ("m" or "monitor") then

  print("monitor running.")
     
  local event = require("event")

  event.timer(1, monitor, math.huge)

else
  print("grape <command>")
  print("(s)eek <n>     -  seek n bytes. n can be negative. can be done while tape is playing")
  print("(r)ewind       - instantly rewind a tape")
  print("(m)onitor      - start monitor mode. in monitor mode, any connected tape drive will automatically insta-rewind on rewind press and at tape end.")
  print("(c)opy <a> <b> - it does things, mostly bad, will brick something. if you value your pc you dont run this.")
  do return false end
end