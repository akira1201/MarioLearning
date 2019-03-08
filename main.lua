-- import
local db = require( 'db' )

-- TODO エミュレータ高速化を有効にする
-- emu.speedmode("nothrottle")

local stateFile = "./MarioTest.State"

math.randomseed(1)

local marioNumber = 0
local numberPerGen = 5
local pixelPerFrame = 0.8

-- まだ使ってないフィールド
-- 変異する確率
local mutationProbability = 0.1
-- 交叉する確率
local crossProbability = 0.1
-- 交叉範囲(sec)
local crossRange = 5

function init ()
	db:init()
end

-- this method executs runOneGen() by Maio will goal
-- @param generation the generation of mario move
-- @param number the indivisual number of generation
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

	writeResultCsv(db:getResult())	
	print("============== Goal ==============")
	print("====", "Generation : ", generation)
	print("====", marioNumber-1, "Marios were dead")	
	print("==================================")
end

-- this method executs run() for all indivisual number of a generation
-- @param generation the generation of mario move
-- @param number the indivisual number of generation
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
			marioCommand = generateCommands(generation,number,currentFrame/60)
		end
		joypad.set(marioCommand, 1)
		emu.frameadvance()
	end
	return successFlg, currentPosition
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

function generateCommands(generation, number, seconds)
	marioCommand = {}
	marioCommand["A"] = math.random(0, 1) == 1
	marioCommand["B"] = math.random(0, 1) == 1
	marioCommand["X"] = math.random(0, 1) == 1
	marioCommand["Y"] = math.random(0, 1) == 1
	marioCommand["L"] = math.random(0, 1) == 1
	marioCommand["R"] = math.random(0, 1) == 1
	marioCommand["Up"] = math.random(0, 1) == 1
	marioCommand["Right"] = math.random(0, 1) == 1
	marioCommand["Down"] = math.random(0, 1) == 1
	marioCommand["Left"] = math.random(0, 1) == 1
	-- TODO ADD YOUR LOGIC
	db:insertCommands(generation,number,currentFrame/60,marioCommand)
	return marioCommand
end

function writeResultCsv(result)
	-- TODO CSVデータがへんだよぉ
	text = ""
	print(result)
	for k, v in pairs(result) do
		if type(v) == "boolean" then
			if v then
				v = 1
			else
				v = 0
			end
		end
		text = text..k..","..v..","
	end
	runningFile = io.open("runningFile.csv", "w")
	runningFile:write(text)
	runningFile:close()
end

init()
execute()
