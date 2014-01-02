-----------------------------------------
--元函数库
--TODO返回字符串：最终返回一个字符串，给界面层使用
--TODO 原函数异常处理，包括类型判断，边界判断等等
-----------------------------------------

local print = print
local type = type
local loadstring = loadstring
local math = math
local pairs = pairs
local error = error
module("BaseLib")

local WriteHZ  = nil
local HZStruct = nil
local RunRule = nil
local WZEnv = nil

--代码运行结果返回信息
allInfoStr = ""
retInfoStr = ""

--#####运行环境设置函数#####--
function clearRetInfoStr()
	retInfoStr = ""
end

function setWriteZiInfo(WZ)
	WriteHZ = WZ
end

function setHZStruct(HS)
	HZStruct = HS
end

function setAllRule(RC)
	RunRule = RC
end


function setWZEnv(env)
	WZEnv = env
end


--#####元函数实现#####--
--所有操作索引从1开始
function GetBH( idx)
	idx = idx + 1
	local bh = WriteHZ.strokes[idx]
	return bh
end

--参数为bd或bh都可
function GetStartPoint(bh)
	local point = WZEnv.POINT:new()
	point.x = bh.ptSet[1].x
	point.y = bh.ptSet[1].y
	return point
end

function GetEndPoint(bh)
	local point = WZEnv.POINT:new()
	point.x = bh.ptSet[#bh.ptSet].x
	point.y = bh.ptSet[#bh.ptSet].y
	return point
end

--获取笔段
function GetBDByBH(bh,bdIdx)
	return bh.BDSet[bdIdx]
end

--获取拐点
function GetInflectionPoint(bh,idx)
	local point = WZEnv.POINT:new()
	local tmpPt = bh.ptSet[bh.InflectionPoint[idx]]
	point.x = tmpPt.x
	point.y = tmpPt.y
	return point
end

--获得笔画拐点的个数
function GetInflectionPtNum (bh)
	return #bh.InflectionPoint
end

--获取笔段数量
 function GetBDNum(bh)
	return #bh.BDSet
 end

 --获得两点间距离
 function GetDistance(pt1,pt2)
	local dis = math.sqrt( math.pow(pt1.x - pt2.x,2) + math.pow(pt1.y - pt2.y,2))
	return dis
 end

 function GetBHLen ( bh )
	local nbd = GetBDNum ( bh)
	local bhlen = 0
	--print (nbd)
	for i = 1, nbd do
		local tmpbd = WZEnv.BD:new()
		tmpbd = bh.BDSet[i]
		local tmpspt = GetStartPoint ( tmpbd )
		local tmpept = GetEndPoint ( tmpbd )
		--print (tmpspt.x .. "xx" .. tmpspt.y)
		--print (tmpept.x .. "xx" .. tmpept.y )

		local bdlen = GetDistance ( tmpspt,tmpept )
		bhlen = bhlen + bdlen
	end
	return bhlen
 end

function trace(var)
	retInfoStr = ""
	local varType = type(var)
	if(varType == "string") then
		retInfoStr = var .. "\r\n"
	end
	if(varType == "table") then
			if(var.GeoType == "KBH") then
			retInfoStr = "KBH:\r\n"
			retInfoStr = retInfoStr .. "start point: "..var.ptSet[1].x..","..var.ptSet[1].y
			retInfoStr = retInfoStr .. "\r\n"
			retInfoStr = retInfoStr .. "end point: "..var.ptSet[#var.ptSet].x..","..var.ptSet[#var.ptSet].y
			retInfoStr = retInfoStr .. "\r\n"
			allInfoStr = allInfoStr .. retInfoStr
			end
	end
	if (varType == "number") then
		retInfoStr = var .. "\r\n"
	end
	allInfoStr = allInfoStr .. retInfoStr
end


--获得中点
function	GetMidPoint ( bh )
 	local point = WZEnv.POINT:new()
	local len= #bh.ptSet
	local tmpIdx = math.floor ( len / 2 )
	point.x = bh.ptSet[tmpIdx].x
	point.y = bh.ptSet[tmpIdx].y
	return point
end

--获得点的横纵坐标
function GetPointX ( pt )
	return pt.x
end

function GetPointY ( pt )
	return pt.y
end

--对于稀疏bd 的插值
--[[function base_Interplotation ( bd )
	local resultBD =
	local ptSize = #bd.ptSet
	for i =1 ,ptSize do
		local pt1 = bd.ptSet[i]
		local pt2 = bd.ptSet[i+1]
		local lengthX = pt2.x - pt1.x
		local lengthY = pt2.y - pt2.y
		local maxLength = 0
		if (math.abs (lengthX) > math.abs (lengthY)) then
			maxLength = lengthX
			else
				maxLength = lengthY
			end
		local increaseX = lengthX / maxLength
		local increaseY = lengthY / maxLength
		local startX = pt1.x
		local startY = pt1.y
		for j = 1, j <maxLength
			local point = WZEnv.POINT:new()
			point.x = startX
			point.y = startY

		end
	end
end
]]


--boolean 判断横是否平
function HorFlat ( bh,threshold )
	if (threshold == nil) then
		return nil
	end
	if ( bh.GeoType ~= "KBD" and bh.GeoType ~= "KBH") then
		return nil
	end
	if ( type (threshold) ~= "number" ) then
	end
	local startpt = WZEnv.POINT:new()
	local endpt = WZEnv.POINT:new()
	startpt = bh.ptSet[1]
	endpt = bh.ptSet[#bh.ptSet]
	local slope = (startpt.y - endpt.y) / (endpt.x - startpt.x)
	--lua中反正切函数返回的本身就是角度而不是弧度。注意与C++中的区别
	local angel = math.deg ( math.atan(slope))
	local angelInter
	local angelFloat
	angelInter,angelFloat = math.modf (angel)
	if (angelFloat > 0.5) then
		angelInter = angelInter + 1
	elseif (angelFloat < -0.5) then
		angelInter = angelInter - 1
	end
	if (math.abs (angelInter )>= threshold) then
		return false
		else
		return true
	end
end

--boolean 判断竖是否直 bh/bd
function VerFlat ( bh,threshold )
	if (threshold == nil) then
	return nil
	end
	if ( bh.GeoType ~= "KBD" and bh.GeoType ~= "KBH") then
	return nil
	end
	local startpt = WZEnv.POINT:new()
	local endpt = WZEnv.POINT:new()
	startpt = bh.ptSet[1]
	endpt = bh.ptSet[#bh.ptSet]
	if( endpt.y - startpt.y == 0) then
		return nil
	end
	local slope = ( endpt.x - startpt.x ) / ( endpt.y - startpt.y )
	local angel = math.deg ( math.atan(slope))
	local angelInter
	local angelFloat
	angelInter,angelFloat = math.modf (angel)
	if (angelFloat > 0.5) then
		angelInter = angelInter + 1
	elseif (angelFloat < -0.5) then
		angelInter = angelInter - 1
	end
	if (math.abs (angelInter )>= threshold) then
		return 0
		else
		return 1
	end
end

--获得最左面的点 bh/bd
function GetLeftMostPoint ( bh )
	if ( bh == nil ) then
		return nil
	end
	if ( bh.GeoType ~= "KBD" and bh.GeoType ~= "KBH" ) then
		return nil
	end
	if ( bh==nil ) then
		return nil
	end
	local pt = WZEnv.POINT:new()
	pt.x , pt.y = 0 , 0
	if ( (#bh.ptSet) > 0 ) then
		pt.x = bh.ptSet[1].x
		pt.y = bh.ptSet[1].y
	end
	for i =1,#bh.ptSet do
		if ( pt.x > bh.ptSet[i].x ) then
			pt.x = bh.ptSet[i].x
			pt.y = bh.ptSet[i].y
			end
	end
	return pt
end

--获得最右面的点 bh/bd
function GetRightMostPoint ( bh )
	if ( bh == nil ) then
		return nil
	end
	if ( bh.GeoType ~= "KBD" and bh.GeoType ~= "KBH" ) then
		return nil
	end
	if ( bh==nil ) then
		return nil
	end
	local pt = WZEnv.POINT:new()
	pt.x , pt.y = 0 , 0
	if ( (#bh.ptSet) > 0 ) then
		pt.x = bh.ptSet[1].x
		pt.y = bh.ptSet[1].y
	end
	for i =1,#bh.ptSet do
		if ( pt.x < bh.ptSet[i].x ) then
			pt.x = bh.ptSet[i].x
			pt.y = bh.ptSet[i].y
			end
	end
	return pt
end

--获得最上方的点
function GetTopMostPoint ( bh )
	if ( bh == nil ) then
		return nil
	end
	if ( bh.GeoType ~= "KBD" and bh.GeoType ~= "KBH" ) then
		return nil
	end
	local pt = WZEnv.POINT:new()
	pt.x , pt.y = 0 , 0
	if ( (#bh.ptSet) > 0 ) then
		pt.x = bh.ptSet[1].x
		pt.y = bh.ptSet[1].y
	end
	for i =1,#bh.ptSet do
		if ( pt.y > bh.ptSet[i].y ) then
			pt.x = bh.ptSet[i].x
			pt.y = bh.ptSet[i].y
			end
	end
	return pt
end

--获得最下方的点 bd/bd
function GetBottomMostPoint ( bh )
	if ( bh == nil ) then
		return nil
	end
	if ( bh.GeoType ~= "KBD" and bh.GeoType ~= "KBH" ) then
		return nil
	end

	local pt = WZEnv.POINT:new()
	pt.x , pt.y = 0 , 0
	if ( (#bh.ptSet) > 0 ) then
		pt.x = bh.ptSet[1].x
		pt.y = bh.ptSet[1].y
	end
	for i =1,#bh.ptSet do
		if ( pt.y < bh.ptSet[i].y ) then
			pt.x = bh.ptSet[i].x
			pt.y = bh.ptSet[i].y
			end
	end
	return pt
end

--获得bh上离pt最近的点
function GetVPoint(bh,pt)
	local minPtIndex = 0
	local minDis = GetDistance(pt,bh.ptSet[1])
	for i = 2,#bh.ptSet do
		local tmpDis = GetDistance(pt,bh.ptSet[i])
		if (tmpDis < minDis) then
			minDis = tmpDis
			minPtIndex = i
		end
	end
	return bh.ptSet[minPtIndex]
end

