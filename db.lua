module("db", package.seeall)

local tbl = { value = 0 }

function tbl:init()
	dbName = "mario_move.db"
	db = SQL.createdatabase(dbName)
	db = SQL.opendatabase(dbName)
	db = SQL.writecommand([[
		CREATE TABLE MarioCommand (
			Generation int,
			Number int,
			Time int,
			IsParent boolean,
			A boolean,
			B boolean,
			X boolean,
			Y boolean,
			L boolean,
			R boolean,
			Up boolean,
			Right boolean,
			Down boolean,
			Left boolean
		)
	]])
	db = SQL.writecommand([[
		INSERT INTO MarioCommand VALUES (1,1,1,0,0,0,0,0,0,0,0,0,0,0);
		]])
end

function tbl:insertCommands(generation,number,seconds,marioCommand)
	sql = "INSERT INTO MarioCommand VALUES ("
		..generation..","..number..","..seconds..","..0
		..","..(marioCommand["A"] and 1 or 0)
		..","..(marioCommand["B"] and 1 or 0)
		..","..(marioCommand["X"] and 1 or 0)
		..","..(marioCommand["Y"] and 1 or 0)
		..","..(marioCommand["L"] and 1 or 0)
		..","..(marioCommand["R"] and 1 or 0)
		..","..(marioCommand["Up"] and 1 or 0)
		..","..(marioCommand["Right"] and 1 or 0)
		..","..(marioCommand["Down"] and 1 or 0)
		..","..(marioCommand["Left"] and 1 or 0)
		..");"
	db = SQL.writecommand(sql)
end

function tbl:upDateIsParent(generation,number)
	sql = "UPDATE MarioCommand"
		.." SET IsParent = 1"
		.." WHERE"
			.." Generation = "..generation
			.." Number = "..number
		..";"
    return SQL.readcommand(sql)
end

function tbl:getSingle(generation,number,seconds)
	sql = "SELECT * FROM MarioCommand WHERE "
		.." Generation = "..generation
		.." Number = "..number
		.." Time = "..seconds
		..";"
    return SQL.readcommand(sql)
end

function tbl:getByIsParent(generation)
	sql = "SELECT * FROM MarioCommand WHERE "
		.." Generation = "..generation
		.." IsParent = 1"
		..";"
    return SQL.readcommand(sql)
end

function tbl:getResult()
	sql = "SELECT * FROM MarioCommand;"
    return SQL.readcommand(sql)
end

return tbl