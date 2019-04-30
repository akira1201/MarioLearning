local mario = require( 'mario' )

local stateFile = "./MarioTest.State"

math.randomseed(1)

local parentMarioList = {}
-- 生成したマリオの数
local marioNumber = 0
-- 世代あたりのマリオの数
local numberPerGen = 10
-- デッドライン(pixel/frame)
local pixelPerFrame = 1.2
-- 変異する確率の最大値(%)
local maxMutationProbability = 20
-- 交叉する確率(%)
local crossProbability =5

-- this method executs runOneGen() by Maio will goal
-- @return Does the run succeed, The Mario's x position
function execute()
	generation = 0
	finishFlg = false
	while true do
		generation = generation + 1
		finishFlg = runOneGen(generation)
		if finishFlg then
			break
		end
	end

	print("============== Goal ==============")
	print("====", "Generation : ", generation)
	print("====", marioNumber-1, "Marios were dead")	
	print("==================================")
end

-- this method executs run() for all indivisual number of a generation
-- @param generation the generation of mario move
-- @return Does the run succeed, The Mario's x position
function runOneGen(generation)
	print("\n******** Generation : ", generation)
	marioList = {}
	for number = 1, numberPerGen do
		successFlg, m = run(generation, number)
		marioList[number] = m
		if successFlg then
			return true
		end
	end
	parentMarioList = selectParentMario(marioList)
	collectgarbage()
	return false
end

-- this method make Mario running after loading the state file
-- @param generation the generation of mario move
-- @param number the indivisual number of generation
-- @return Does the run succeed, The Mario's x position
function run(generation, number)
	marioNumber = marioNumber +1
	print("--- Number : ", number)
	m = mario:new()
	m:setInfo(generation,number)

	successFlg = false
	savestate.load(stateFile)
	startFrame = emu.framecount()
	startPosition = memory.readbyte(0x95)*256 + memory.readbyte(0x94)

	while true do
		currentPosition = memory.readbyte(0x95)*256 + memory.readbyte(0x94) - startPosition
		currentFrame = emu.framecount() - startFrame
		finishFlg, successFlg = checkFinished(currentPosition, currentFrame)
		if finishFlg == true then
			break
		end
		if currentFrame%60 == 0 then
			currentTime = currentFrame/60
			marioCommand = getCommand(generation,number,currentTime,currentPosition,m)
			m:setCommand(currentTime,marioCommand)
		end
		joypad.set(marioCommand, 1)
		emu.frameadvance()
	end

	m:setTime(currentTime)
	print(" distance:",currentPosition, "\n")
	m:setDistance(currentPosition)
	return successFlg, m
end

function selectParentMario(marioList)
	table.sort(marioList, function(a,b) 
		return a:getDistance() > b:getDistance() end)
	-- for num,m in ipairs(marioList) do
	-- 	print(num, m:getDistance())
	-- end
	return {marioList[1], marioList[2]}
end

function checkFinished(currentPosition, currentFrame)
	-- is goal
	if memory.readbyte(0x1493) == 255 then
		print(currentPosition/currentFrame)
		return true, true
	end
	-- is dead
	if memory.readbyte(0x71) == 9 then
		return true, false
	end
	-- too slow
	if currentFrame >= 60 and currentPosition/currentFrame < pixelPerFrame then
		return true, false
	end
	return false, false
end

function getCommand(gen, number, seconds, position, m)
	-- all the first generation Marios move random
	if gen == 1 then
		return mario:generateCommand()
	end

	-- same to parent for saving elete
	-- TODO not to run by same command
	if number == 1 then
		return parentMarioList[1]:getCommand(seconds)
	end
	if number == 2 then
		return parentMarioList[2]:getCommand(seconds)
	end

	-- setting base mario
	if number%2==1 then
		baseParent = parentMarioList[1]
		otherParent = parentMarioList[2]
	else
		baseParent = parentMarioList[2]
		otherParent = parentMarioList[1]
	end

	-- crossing
	crossing = math.random(0, 99) < crossProbability
	if crossing then
		m:changeIsCrossing()
	end
	if m:getIsCrossing() then
		command = baseParent:getCommand(seconds)
	else
		command = otherParent:getCommand(seconds)
	end

	-- mutation
	time = baseParent:getTime()
	mutationProbability = maxMutationProbability
	if seconds < time then
		-- It is easy to mutate as Mario move forward
		mutationProbability = seconds/time*maxMutationProbability
	end
	if math.random(0, 99) < mutationProbability then
		command = mario:generateCommand()
	end
	return command
end

execute()
