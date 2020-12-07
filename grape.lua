-- -- -- -- Imports -- -- -- --
local c = require("component")
local arg = {...}

-- Get all tapes
local tapes = {}
for address, name in c.list("tape_drive", true) do
  table.insert(tapes, c.proxy(address))
end

-- Primary tape drive, used for most functions
local tape = c.tape_drive

-- -- -- -- Module -- -- -- --
local grape = {}

-- Seek to byte n on a cassette
function grape.seek(n)
  tape.seek(n)
end

-- Won't work as OpenComputers event if it's a module function?
function monitor()
  -- Run over all tapes
  for _, t in ipairs(tapes) do
      if t.isEnd() then
        grape.seek(-t.getPosition())
      end
      if t.getState() == "REWINDING" then    
        grape.seek(-t.getPosition())
      end
  end
end

-- Smart tape drive monitor - run as threaded event
function grape.monitor()
  monitor()
end

-- -- -- -- Main -- -- -- --

-- Are we a library?
if not pcall(getfenv, 4) then
  
  -- No
  if arg[1] == ("s" or "seek") then

    local n =  tonumber(arg[2])

    if type(n) ~= "number" then
      print("Err: arg 2 must be num")
      do return false end
    end
    
    if not tape.isReady() then
      print("Err: no tape")
      do return false end
    end

    grape.seek(n)

    do return true end

  elseif arg[1] == ("r" or "rewind") then
    
    if not tape.isReady() then
      print("Err: no tape")
      do return false end
    end

    grape.seek(-tape.getPosition())

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
    print("grape works on your primary hard drive. In monitor mode, grape looks at all drives.")
    print("(s)eek <n>     -  seek n bytes. n can be negative. can be done while tape is playing")
    print("(r)ewind       - instantly rewind a tape")
    print("(m)onitor      - start monitor mode. in monitor mode, any connected tape drive will automatically insta-rewind on rewind press and at tape end.")
    print("(c)opy <a> <b> - it does things, mostly bad, will brick something. if you value your pc you dont run this.")
    do return grape end
  end
else
  -- Yes
  do return grape end
end
