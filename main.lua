local mario = require( 'mario' )

local stateFile = "./MarioTest.State"

math.randomseed(1)

local parentMarioList = {}
-- 生成したマリオの数
local marioNumber = 0
-- 世代あたりのマリオの数
local numberPerGen = 5
-- デッドライン(pixel/frame)
local pixelPerFrame = 0.8

-- まだ使ってない
-- 変異する確率
local mutationProbability = 0.1
-- 交叉する確率
local crossProbability = 0.1
-- 交叉範囲(sec)
local crossRange = 5

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
	print("******** Generation : ", generation)
	for number = 1, numberPerGen do
		successFlg, position = run(generation, number)
		if successFlg then
			return true
		end
	end
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
			marioCommand = getCommand(generation,number,currentFrame/60,m)

		end
		joypad.set(marioCommand, 1)
		emu.frameadvance()
	end

	m:setDistance(currentPosition)
	return successFlg, m
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

function getCommand(generation, number, seconds, m)
	command = m:getCommand(seconds)
	-- TODO add your logic
	return command
end

execute()
