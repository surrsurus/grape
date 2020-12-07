local tape = require("component").tape_drive

local grape = {}

-- Seek to byte n on a cassette
function grape.seek(n)
  tape.seek(n)
end

-- Smart tape drive monitor - run as threaded event
function grape.monitor()

  -- while true do
  if tape.isEnd() then
    seek(-tape.getPosition())
  end
  if tape.getState() == "REWINDING" then    
    seek(-tape.getPosition())
  end
  -- os.execute("sleep " .. tonumber(0.5))

end

function grape.rewind()

  seek(-tape.getPosition())
  
  do return true end

function grape.startMonitor(timer)
  print("monitor running.")

  timer = timer or 0.5

  -- Runs as thread
  local event = require("event")
  -- Make this 1 if you want more CPU
  event.timer(timer, monitor, math.huge)


  return grape