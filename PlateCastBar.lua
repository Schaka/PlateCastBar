local AddOn = "PlateCastBar"

local Table = {
	["Nameplates"] = {},
	["CheckButtons"] = {
		["Test"] = {
			["PointX"] = 170,
			["PointY"] = -10,
		},
		["Player Pet"] = {
			["PointX"] = 300,
			["PointY"] = -90,
		},
		["Icon"] = {
			["PointX"] = 300,
			["PointY"] = -120,
		},
		["Timer"] = {
			["PointX"] = 300,
			["PointY"] = -150,
		},
		["Spell"] = {
			["PointX"] = 300,
			["PointY"] = -180,
		},
	},
}
local Textures = {
	Font = "Interface\\AddOns\\" .. AddOn .. "\\Textures\\DorisPP.ttf",
	CastBar = "Interface\\AddOns\\" .. AddOn .. "\\Textures\\LiteStep.tga",
}
_G[AddOn .. "_SavedVariables"] = {
	["CastBar"] = {
		["Width"] = 105,
		["PointX"] = 15,
		["PointY"] = -5,
	},
	["Icon"] = {
		["PointX"] = -62,
		["PointY"] = 0,
	},	
	["Timer"] = {
		["Anchor"] = "RIGHT",
		["PointX"] = 52,
		["PointY"] = 0,
		["Format"] = "LEFT"
	},	
	["Spell"] = {
		["Anchor"] = "LEFT",
		["PointX"] = -53,
		["PointY"] = 0,
	},	
	["Enable"] = {
		["Test"] = false,
		["Player Pet"] = true,
		["Icon"] = true,
		["Timer"] = true,
		["Spell"] = true,
	},
}

local numChildren = -1
local function HookFrames(...)
	for ID = 1,select('#', ...) do
		local frame = select(ID, ...)
		local region = frame:GetRegions()
		if ( not Table["Nameplates"][frame] and not frame:GetName() and region and region:GetObjectType() == "Texture" and region:GetTexture() == "Interface\\Tooltips\\Nameplate-Border" ) then
			Table["Nameplates"][frame] = true
		end
	end
end

local Frame = CreateFrame("Frame")
Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
local function Frame_RegisterEvents()
	Frame:RegisterEvent("UNIT_SPELLCAST_START")
	Frame:RegisterEvent("UNIT_SPELLCAST_DELAYED")
	Frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
	Frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
	Frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	Frame:RegisterEvent("UNIT_SPELLCAST_FAILED")
	Frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	Frame:RegisterEvent("PLAYER_TARGET_CHANGED")
	Frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
end
Frame:SetScript("OnEvent",function(self,event,unitID,spell,...)
	local timestamp, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags = ...
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		local function CastBars_Create()
			local function UnitCastBar_Create(unit)
				_G[AddOn .. "_Frame_" .. unit .. "CastBar"] = CreateFrame("Frame",nil);
				local CastBar = _G[AddOn .. "_Frame_" .. unit .. "CastBar"]
				CastBar:SetFrameStrata("BACKGROUND");
				CastBar:SetWidth(_G[AddOn .. "_SavedVariables"]["CastBar"]["Width"]);
				CastBar:SetHeight(11);
				CastBar:SetPoint("CENTER");
				
				_G[AddOn .. "_Texture_" .. unit .. "CastBar_CastBar"] = CastBar:CreateTexture(nil,"ARTWORK");
				local Texture = _G[AddOn .. "_Texture_" .. unit .. "CastBar_CastBar"]
				Texture:SetHeight(11);	
				Texture:SetTexture(Textures.CastBar);
				Texture:SetPoint("CENTER",AddOn .. "_Frame_" .. unit .. "CastBar","CENTER");

				_G[AddOn .. "_Texture_" .. unit .. "CastBar_Icon"] = CastBar:CreateTexture(nil,"ARTWORK");
				local Icon = _G[AddOn .. "_Texture_" .. unit .. "CastBar_Icon"]
				Icon:SetHeight(13);
				Icon:SetWidth(13);
				Icon:SetPoint("CENTER",AddOn .. "_Frame_" .. unit .. "CastBar","CENTER",
				_G[AddOn .. "_SavedVariables"]["Icon"]["PointX"],
				_G[AddOn .. "_SavedVariables"]["Icon"]["PointY"]);		
				if ( _G[AddOn .. "_SavedVariables"]["Enable"]["Icon"] ) then
					Icon:Show()
				else
					Icon:Hide()
				end
				
				_G[AddOn .. "_Texture_" .. unit .. "CastBar_IconBorder"] = CastBar:CreateTexture(nil,"BACKGROUND");
				local IconBorder = _G[AddOn .. "_Texture_" .. unit .. "CastBar_IconBorder"]
				IconBorder:SetHeight(16);
				IconBorder:SetWidth(16);
				IconBorder:SetPoint("CENTER",Icon,"CENTER");		
				if ( _G[AddOn .. "_SavedVariables"]["Enable"]["Icon"] ) then
					IconBorder:Show()
				else
					IconBorder:Hide()
				end
								
				_G[AddOn .. "_FontString_" .. unit .. "CastBar_SpellName"] = CastBar:CreateFontString(nil)
				local SpellName = _G[AddOn .. "_FontString_" .. unit .. "CastBar_SpellName"]
				SpellName:SetFont(Textures.Font,9,"OUTLINE")
				SpellName:SetPoint(_G[AddOn .. "_SavedVariables"]["Spell"]["Anchor"],
					AddOn .. "_Frame_" .. unit .. "CastBar","CENTER",
					_G[AddOn .. "_SavedVariables"]["Spell"]["PointX"],
					_G[AddOn .. "_SavedVariables"]["Spell"]["PointY"]);		
				if ( _G[AddOn .. "_SavedVariables"]["Enable"]["Spell"] ) then
					SpellName:Show()
				else
					SpellName:Hide()
				end
				
				_G[AddOn .. "_FontString_" .. unit .. "CastBar_CastTime"] = CastBar:CreateFontString(nil)
				local CastTime = _G[AddOn .. "_FontString_" .. unit .. "CastBar_CastTime"]
				CastTime:SetFont(Textures.Font,9,"OUTLINE")
				CastTime:SetPoint(_G[AddOn .. "_SavedVariables"]["Timer"]["Anchor"],
					AddOn .. "_Frame_" .. unit .. "CastBar","CENTER",
					_G[AddOn .. "_SavedVariables"]["Timer"]["PointX"],
					_G[AddOn .. "_SavedVariables"]["Timer"]["PointY"]);		
				if ( _G[AddOn .. "_SavedVariables"]["Enable"]["Timer"] ) then
					CastTime:Show()
				else
					CastTime:Hide()
				end
				
				_G[AddOn .. "_Texture_" .. unit .. "CastBar_Border"] = CastBar:CreateTexture(nil,"BACKGROUND");
				local Border =_G[AddOn .. "_Texture_" .. unit .. "CastBar_Border"]
				Border:SetPoint("CENTER",AddOn .. "_Frame_" .. unit .. "CastBar","CENTER");
				Border:SetWidth(_G[AddOn .. "_SavedVariables"]["CastBar"]["Width"]+5);
				Border:SetHeight(16);	

				local Background = CastBar:CreateTexture(nil,"BORDER");
				Background:SetTexture(1/10, 1/10, 1/10, 1);
				Background:SetAllPoints(AddOn .. "_Frame_" .. unit .. "CastBar");
			end
			UnitCastBar_Create("pet")
			UnitCastBar_Create("focus")
			UnitCastBar_Create("target")
			for i=1,4 do
				UnitCastBar_Create("party"..i)
			end
		end
		if ( not _G[AddOn .. "_PlayerEnteredWorld"] ) then
			Frame_RegisterEvents()
			CastBars_Create()
			ChatFrame1:AddMessage("|cff00ccff" .. AddOn .. "|cffffffff Loaded")
			_G[AddOn .. "_PlayerEnteredWorld"] = true
		end	
	end	
	local function Casting_Event(unit)
		if ( event == "UNIT_SPELLCAST_START" ) then
			if ( unitID == unit ) then 
				_G[AddOn .. "_" .. unit .. "_Fading"] = false
				local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(unit);
				_G[AddOn .. "_" .. unit .. "_Casting"] = true
				if ( string.len(name) > 12 ) then name = (string.sub(name,1,12) .. ".. ") end	
				_G[AddOn .. "_FontString_" .. unit .. "CastBar_SpellName"]:SetText(name)
				_G[AddOn .. "_Frame_" .. unit .. "CastBar"]:SetAlpha(1)
				_G[AddOn .. "_Texture_" .. unit .. "CastBar_Icon"]:SetTexture(texture)
				_G[AddOn .. "_Texture_" .. unit .. "CastBar_CastBar"].value = (GetTime() - (startTime / 1000));
				_G[AddOn .. "_Texture_" .. unit .. "CastBar_CastBar"].maxValue = (endTime - startTime) / 1000;	
				_G[AddOn .. "_Texture_" .. unit .. "CastBar_CastBar"]:SetVertexColor(1, 0.5, 0)
			end
		elseif ( event == "UNIT_SPELLCAST_CHANNEL_START" ) then
			if ( unitID == unit ) then 
				_G[AddOn .. "_" .. unit .. "_Fading"] = false
				local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(unit);
				_G[AddOn .. "_" .. unit .. "_Channeling"] = true
				if ( string.len(name) > 12 ) then name = (string.sub(name,1,12) .. ".. ") end	
				_G[AddOn .. "_FontString_" .. unit .. "CastBar_SpellName"]:SetText(name)
				_G[AddOn .. "_Frame_" .. unit .. "CastBar"]:SetAlpha(1)
				_G[AddOn .. "_Texture_" .. unit .. "CastBar_Icon"]:SetTexture(texture)
				_G[AddOn .. "_Texture_" .. unit .. "CastBar_CastBar"].value = (GetTime() - (startTime / 1000));
				_G[AddOn .. "_Texture_" .. unit .. "CastBar_CastBar"].maxValue = (endTime - startTime) / 1000;	
				_G[AddOn .. "_Texture_" .. unit .. "CastBar_CastBar"]:SetVertexColor(1, 0.5, 0)
			end
		elseif ( event == "UNIT_SPELLCAST_DELAYED" ) then
			if ( unitID == unit ) then 
				local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(unit);
				_G[AddOn .. "_Texture_" .. unit .. "CastBar_CastBar"].value = (GetTime() - (startTime / 1000));
				_G[AddOn .. "_Texture_" .. unit .. "CastBar_CastBar"].maxValue = (endTime - startTime) / 1000;
			end
		elseif ( event == "UNIT_SPELLCAST_CHANNEL_UPDATE" ) then
			if ( unitID == unit ) then 
				local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(unit);
				_G[AddOn .. "_Texture_" .. unit .. "CastBar_CastBar"].value = (GetTime() - (startTime / 1000));
				_G[AddOn .. "_Texture_" .. unit .. "CastBar_CastBar"].maxValue = (endTime - startTime) / 1000;
			end
		elseif ( event == "UNIT_SPELLCAST_FAILED" ) then
			if ( _G[AddOn .. "_" .. unit .. "_Casting"] == true and unitID == unit ) then
				_G[AddOn .. "_" .. unit .. "_Casting"] = false
				_G[AddOn .. "_" .. unit .. "_Channeling"] = false
			end
		elseif ( event == "UNIT_SPELLCAST_SUCCEEDED" ) then
			if ( _G[AddOn .. "_" .. unit .. "_Casting"] and unitID == unit ) then
				_G[AddOn .. "_Texture_" .. unit .. "CastBar_CastBar"]:SetVertexColor(0, 1, 0)
				_G[AddOn .. "_" .. unit .. "_Fading"] = true
				_G[AddOn .. "_" .. unit .. "_Casting"] = false
			end
		end
	end
	Casting_Event("pet")
	Casting_Event("focus")
	Casting_Event("target")			
	for i=1,4 do
		Casting_Event("party"..i)
	end
	if ( event == "PLAYER_TARGET_CHANGED" and UnitGUID("target") ~=nil) then
		event = "UNIT_SPELLCAST_START"
		unitID = "target"
		Casting_Event("target")
	end
	if ( event == "PLAYER_FOCUS_CHANGED" and UnitGUID("focus") ~=nil) then
		event = "UNIT_SPELLCAST_START"
		unitID = "focus"
		Casting_Event("focus")
	end
	
  	local function Spell_Interrupt()
		if ( event == "COMBAT_LOG_EVENT_UNFILTERED" ) then
			if ( eventType == "SPELL_INTERRUPT" ) then
				local function Units_Check(unit)
					if ( destGUID ==  UnitGUID(unit) ) then
						_G[AddOn .. "_Texture_" .. unit .. "CastBar_CastBar"]:SetVertexColor(1, 0, 0)
						_G[AddOn .. "_" .. unit .. "_Casting"] = false
						_G[AddOn .. "_" .. unit .. "_Channeling"] = false
						_G[AddOn .. "_" .. unit .. "_Fading"] = true
					end
				end
				Units_Check("pet")
				Units_Check("focus")
				Units_Check("target")			
				for i=1,4 do
					Units_Check("party"..i)
				end
			end	
		end	
	end	
	Spell_Interrupt()
end)
Frame:SetScript("OnUpdate", function(self, elapsed)
	local function WorldFrames_Check()
		if ( WorldFrame:GetNumChildren() ~= numChildren ) then
			numChildren = WorldFrame:GetNumChildren()
			HookFrames(WorldFrame:GetChildren())		
		end
	end
	WorldFrames_Check()	
	
	local function NamePlatesName_Check()
		local name1,name2,name3,name4,petname,focusname,targetname
		local function FrameName_Check(frame)
			local hpborder, cbborder, cbicon, overlay, oldname, level, bossicon, raidicon = frame:GetRegions()
			local name = oldname:GetText()
			if ( name == UnitName("pet") ) then
				petname = true
			end
			for id = 1,4 do
				if ( name == UnitName("party" .. id) ) then
					_G["name" .. id] = true
				end
			end
			if ( name == UnitName("target") ) then
				_G["targetname"] = true
			end
			if ( name == UnitName("focus") ) then
				_G["focusname"] = true
			end
		end
		for frame in pairs(Table["Nameplates"]) do
			FrameName_Check(frame)
		end
		for id = 1,4 do
			if ( _G["name"..id] ) then
				_G[AddOn .. "_Frame_party" .. id .. "CastBar"]:Show()
			else
				_G[AddOn .. "_Frame_party" .. id .. "CastBar"]:Hide()
			end
		end
		if ( targetname ) then
			_G[AddOn .. "_Frame_targetCastBar"]:Show()
		end
		if ( focusname ) then
			_G[AddOn .. "_Frame_focusCastBar"]:Show()
		end
		if ( petname  and _G[AddOn .. "_SavedVariables"]["Enable"]["Player Pet"] == true ) then
			_G[AddOn .. "_Frame_petCastBar"]:Show()
		else
			_G[AddOn .. "_Frame_petCastBar"]:Hide()
		end
		petname = false
	end
	NamePlatesName_Check()	

	local function Position_Update()
		local function NamePlate_Update(frame)
			local hp = frame:GetChildren()
			local hpborder, cbborder, cbicon, overlay, oldname, level, bossicon, raidicon = frame:GetRegions()
			local name = oldname:GetText()
			
			if ( name == UnitName("pet") and hp:GetValue() == UnitHealth("pet") and frame:IsShown() ) then
				_G[AddOn .. "_Frame_petCastBar"]:SetPoint("TOP",hp,"BOTTOM",
					_G[AddOn .. "_SavedVariables"]["CastBar"]["PointX"],
					_G[AddOn .. "_SavedVariables"]["CastBar"]["PointY"]);
				_G[AddOn .. "_Frame_petCastBar"]:SetParent(frame)
			end
			for i=1,4 do
				if ( name == UnitName("party"..i) and hp:GetValue() == UnitHealth("party"..i) and frame:IsShown() ) then
					_G[AddOn .. "_Frame_party".. i .. "CastBar"]:SetPoint("TOP",hp,"BOTTOM",6,-4.5)
					_G[AddOn .. "_Frame_party".. i .. "CastBar"]:SetParent(frame)
				end
			end
			if ( name == UnitName("target") and hp:GetValue() == UnitHealth("target") and frame:IsShown() ) then
					_G[AddOn .. "_Frame_targetCastBar"]:SetPoint("TOP",hp,"BOTTOM",6,-4.5)
					_G[AddOn .. "_Frame_targetCastBar"]:SetParent(frame)
			end
			if ( name == UnitName("focus") and hp:GetValue() == UnitHealth("focus") and frame:IsShown() ) then
					_G[AddOn .. "_Frame_focusCastBar"]:SetPoint("TOP",hp,"BOTTOM",6,-4.5)
					_G[AddOn .. "_Frame_focusCastBar"]:SetParent(frame)
			end
		end
		for frame in pairs(Table["Nameplates"]) do
			NamePlate_Update(frame)
		end
	end
	Position_Update()
	
	local function CastBars_Update()
		local function Casting_Update(unit)
			local Casting = _G[AddOn .. "_" .. unit .. "_Casting"]
			local Channeling = _G[AddOn .. "_" .. unit .. "_Channeling"]
			local CastBar = _G[AddOn .. "_Frame_" .. unit .. "CastBar"]
			local Texture = _G[AddOn .. "_Texture_" .. unit .. "CastBar_CastBar"]
			local Border = _G[AddOn .. "_Texture_" .. unit .. "CastBar_Border"]
			local IconBorder = _G[AddOn .. "_Texture_" .. unit .. "CastBar_IconBorder"]
			local Fading =  _G[AddOn .. "_" .. unit .. "_Fading"]
			local CastTime = _G[AddOn .. "_FontString_" .. unit .. "CastBar_CastTime"]
			local Width = _G[AddOn .. "_SavedVariables"]["CastBar"]["Width"]
			local Enabled

			
			if ( not Fading or not _G[AddOn .. "_" .. unit .. "CastBarAlpha"] ) then
				_G[AddOn .. "_" .. unit .. "CastBarAlpha"] = 0
			end
			if ( unit == "pet" ) then
				Enabled = _G[AddOn .. "_SavedVariables"]["Enable"]["Player Pet"]
			end
			for i=1, 4 do
				if ( unit == "party"..i ) then
					Enabled = true
				end
			end
			if ( unit == "target" ) then
					Enabled = true
			end
			if ( unit == "focus" ) then
					Enabled = true
			end
			if ( Enabled ) then
				if ( Channeling and not UnitChannelInfo(unit) ) then
					Texture:SetVertexColor(0, 1, 0)
					_G[AddOn .. "_" .. unit .. "_Fading"] = true
					_G[AddOn .. "_" .. unit .. "_Channeling"] = false
				elseif ( Casting and not Fading and UnitCastingInfo(unit) ) then
					local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(unit);	
					if ( endTime ) then
						local total = string.format("%.2f",(endTime-startTime)/1000)
						local left = string.format("%.1f",total - Texture.value/Texture.maxValue*total)
						if ( _G[AddOn .. "_SavedVariables"]["Timer"]["Format"] == "LEFT" ) then
							CastTime:SetText(left)
						elseif ( _G[AddOn .. "_SavedVariables"]["Timer"]["Format"] == "TOTAL" ) then
							CastTime:SetText(total)
						elseif ( _G[AddOn .. "_SavedVariables"]["Timer"]["Format"] == "BOTH" ) then
							CastTime:SetText(left .. " /" .. total)
						end	
					end	
					if ( not notInterruptible ) then
						Border:SetTexture(0,0,0,1)
						IconBorder:SetTexture(0,0,0,1)
					else
						Border:SetTexture(1,0,0,1)
						IconBorder:SetTexture(1,0,0,1)
					end
					Texture.value = Texture.value + elapsed
					if ( Texture.value >= Texture.maxValue ) then return end
					Texture:SetWidth(Width*Texture.value/Texture.maxValue)
					point, relativeTo, relativePoint, xOfs, yOfs = Texture:GetPoint()
					Texture:SetPoint(point, relativeTo, relativePoint, -Width/2+Width/2*Texture.value/Texture.maxValue, yOfs)
				elseif ( Channeling and not Fading ) then
					local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(unit);
					if ( endTime ) then
						local total = string.format("%.2f",(endTime-startTime)/1000)
						local left = string.format("%.1f",total - Texture.value/Texture.maxValue*total)
						if ( _G[AddOn .. "_SavedVariables"]["Timer"]["Format"] == "LEFT" ) then
							CastTime:SetText(left)
						elseif ( _G[AddOn .. "_SavedVariables"]["Timer"]["Format"] == "TOTAL" ) then
							CastTime:SetText(total)
						elseif ( _G[AddOn .. "_SavedVariables"]["Timer"]["Format"] == "BOTH" ) then
							CastTime:SetText(left .. " /" .. total)
						end	
					end	
					if ( not notInterruptible ) then
						Border:SetTexture(0,0,0,1)				
						IconBorder:SetTexture(0,0,0,1)				
					else
						Border:SetTexture(1,0,0,1)
						IconBorder:SetTexture(1,0,0,1)
					end
					Texture.value = Texture.value + elapsed
					if ( Texture.value >= Texture.maxValue ) then return end
					Texture:SetWidth(Width*(Texture.maxValue-Texture.value)/Texture.maxValue)
					point, relativeTo, relativePoint, xOfs, yOfs = Texture:GetPoint()
					Texture:SetPoint(point, relativeTo, relativePoint, -Width/2*Texture.value/Texture.maxValue, yOfs)
				elseif ( Fading ) then
					if ( Channeling or Casting or _G[AddOn .. "_" .. unit .. "CastBarAlpha"] >= 0.5 ) then
						_G[AddOn .. "_" .. unit .. "CastBarAlpha"] = 0
						_G[AddOn .. "_" .. unit .. "_Fading"] = false
						return
					end	
					_G[AddOn .. "_" .. unit .. "CastBarAlpha"] = _G[AddOn .. "_" .. unit .. "CastBarAlpha"] + elapsed
					CastBar:SetAlpha(1-(2*_G[AddOn .. "_" .. unit .. "CastBarAlpha"]))
				elseif ( CastBar ) then
					CastBar:SetAlpha(0)
				end
			end
		end
		Casting_Update("pet")
		Casting_Update("focus")
		Casting_Update("target")			
		for i=1,4 do
			Casting_Update("party"..i)
		end
		
	end
	CastBars_Update() 
end)