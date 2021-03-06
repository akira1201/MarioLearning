math.randomseed(1)

local _M = {}
local _ = {}
setmetatable(_, {__mode = "k"})

function _M:new(o)
    o = o or {}
    _[o] = {}
    self.__index = self
    return setmetatable(o,self)
end

function _M:setInfo(g,n)
    _[self].gen = g
    _[self].num = n
    _[self].commands = {}
    _[self].distance = 0
    _[self].time = 0
    _[self].isCrossing = false
end

function _M:getGen()
    return _[self].gen
end

function _M:getNum()
    return _[self].num
end

function _M:setCommand(t,c)
    _[self].commands[t] = c
end

function _M:getCommand(t)
    command = _[self].commands[t]
    if command == nil then
        command = _M:generateCommand()
        _[self].commands[t] = command
    end
    return command
end

function _M:setDistance(d)
    _[self].distance = d
end

function _M:getDistance()
    return _[self].distance
end

function _M:setTime(t)
    _[self].Time = t
end

function _M:getTime()
    return _[self].Time
end

function _M:changeIsCrossing()
    if _[self].isCrossing then
        _[self].isCrossing = false
    else 
        _[self].isCrossing = true
    end
end

function _M:getIsCrossing()
    return _[self].isCrossing
end

function _M:generateCommand()
    command = {}
    command["A"] = math.random(0, 1) == 1
    command["B"] = math.random(0, 1) == 1
    command["X"] = math.random(0, 1) == 1
    command["Y"] = math.random(0, 1) == 1
    command["L"] = math.random(0, 1) == 1
    command["R"] = math.random(0, 1) == 1
    command["Up"] = math.random(0, 1) == 1
    command["Right"] = math.random(0, 1) == 1
    command["Down"] = math.random(0, 1) == 1
    command["Left"] = math.random(0, 1) == 1
    return command
end

-- function _M:showPrivateTable()
-- 	for k1, v1 in pairs(_) do
-- 		for k2, v2 in pairs(v1) do
-- 			print(k2, v2)
-- 		end
-- 	end
-- end

return _M
