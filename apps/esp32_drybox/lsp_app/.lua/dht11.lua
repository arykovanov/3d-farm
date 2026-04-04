local cResume, cYield = coroutine.resume, coroutine.yield

local DEBUG <const> = false

local function dtrace(msg, ...)
  if DEBUG then
    trace(string.format(msg, ...))
  end
end

local function bit(symbols, zbit)
  local sym = symbols[zbit+1]
  if not sym then
     raise("invalid symbols")
  end
  if sym[1] ~= 0 then
     raise("invalid low level")
  end
  if sym[2] < 49 or sym[2] > 61 then
     raise("invalid low time")
  end
  if sym[3] ~= 1 then
     raise("invalid high level")
  end
  if sym[4] < 15 or sym[4] > 68 then
     raise("invalid high time")
  end
  if sym[4] > 30 then
     return 1
  end

  return 0
end

local function getByte(symbols, zidx)
  local byte = 0
  local off <const> = zidx*8
  for zbit = off,off+7 do
     byte = (byte << 1) | bit(symbols, zbit)
  end
  return byte
end

local function decodeDHT11(symbols)
  if #symbols < 40 then
    raise("too few symbols")
  end

 -- Sorry, zero based indexes...
  local byte1 = getByte(symbols, 0)
  local byte2 = getByte(symbols, 1)
  local byte3 = getByte(symbols, 2)
  local byte4 = getByte(symbols, 3)
  local byte5 = getByte(symbols, 4)
  local sum = (byte1 + byte2 + byte3 + byte4) & 0xFF
--   trace(string.format("byte1=%s, byte2=%s, byte3=%s, byte3=%s, byte5=%s, sum=%s", byte1,byte2,byte3,byte4,byte5,sum))

 if sum ~= byte5 then
   raise("checkum")
 end

 return byte1 + (byte2%10)/10, byte3 + (byte4%10)/10
end

local function exec(coro, gpio, callback)
  dtrace("Creating RX")
  local suc, rx <close> = pcall(esp32.rmtrx, {gpio=gpio,resolution=1000000,callback = function(d, overflow)
     cResume(coro, d, overflow and "overflow")
  end})

  if not suc then
    callback(rx)
    return
  end

  dtrace("Creating TX")
  local tx <close> = esp32.rmttx({gpio=gpio, resolution=1000000, opendrain=true},rx)

  dtrace("Create timeout")
  local timeout = false
  local timer = ba.timer(function()
     dtrace("Timer called")
     timeout = true
     dtrace("Ping coroutine")
     local res1,res2 = cResume(coro, nil, "timeout")
     dtrace("Coroutine pinged", res, res2)
  end)
  dtrace("Enable TX")
  tx:enable()

  dtrace("Start receiving")
  -- Prepare RX to start capture after TX is done
  rx:receive{min=30, max=200000, len=40, defer=true}
  -- Send start signal: LOW 18 ms, HIGH 40 µs
  dtrace("Send request to sensor")
  tx:transmit({eot=1}, {
     {0, 18000, 1, 40}
  })

  dtrace("Set timer")
  timer:set(1000)
  dtrace("Waiting for data")
  local symbols, err = cYield()
  if not timeout then
    dtrace("Cancel timer")
    timer:cancel()
  end
  if err then
     dtrace("Receive error: %s", err)
     callback(nil, nil, err)
     return
  end

  dtrace(string.format("Received %s rmt-symbols: ", #symbols))
  if DEBUG then
    for i,sym in ipairs(symbols) do
       dtrace("%d: {%s, %s, %s, %s}", i, sym[1],sym[2],sym[3],sym[4])
    end
  end
  dtrace("Decoding symbols")
  local suc, a, b = pcall(decodeDHT11, symbols)
  if not suc then
    callback(nil, nil, a)
  else
    callback(a, b, nil)
  end
end

local function dht11(gpio, callback)
   dtrace("Create coroutine")
   local coro = coroutine.create(exec)
   dtrace("Resume coroutine")
   cResume(coro, coro, gpio, callback)
end

return dht11
