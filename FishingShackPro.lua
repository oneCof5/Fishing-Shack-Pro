--[[ Fishing Shack Pro
This is a simple addon that checks our inventory for item upgrades
(fishing poles and fishing hats) when it thinks that we are fishing.
If an upgraded item is found in our inventory, it will be equipped.
Note: "Fishing" is defined as equipping a fishing pole.

-- Many thanks to Torhal for code cleanup suggestions!
-- http://forums.curseforge.com/member.php?u=33600
]]--

local addon, ns = ...
local ENABLE_FSP = true -- assume we start enabled
local TYPE_FISHING_POLES = select(7, GetItemInfo(6256)) -- get localized sub-type for the basic fishing pole (i.e. "Fishing Poles")

-- define English language slugs
local L = {}
L["Now using"] = "Now using"
L["replaced by"] = "replaced by"
L["UPGRADE!"] = "UPGRADE!"
L["commands"] = "commands"
L["ON"] = "ON"
L["OFF"] = "OFF"
L["Yes"] = "Yes"
L["No"] = "No"
L["enable the addon"] = "enable the addon"
L["replace poles with active bait applied"] = "replace poles with active bait applied"

-- define a fishing pole table sorted by an arbitrary 'best' order
-- note ARBITRARY
local fishPoles = {
-- ID        Name                               +Skill  +Other            Faction?
"133755", -- Underlight Angler                   60      Teleport to node
"118381", -- Ephemeral Fishing Pole             100
"19970" , -- Arcanite Fishing Pole               40
"116826", -- Draenic Fishing Pole                30      Lure +200        Alliance
"116825", -- Savage Fishing Pole                 30      Lure +200        Horde
"44050" , -- Mastercraft Kalu'ak Fishing Pole    30      Waterbreathing
"45991" , -- Bone Fishing Pole                   30
"45992" , -- Jeweled Fishing Pole                30
"84661" , -- Dragon Fishing Pole                 30
"45858" , -- Nat's Lucky Fishing Pole            25
"6367"  , -- Big Iron Fishing Pole               20
"19022" , -- Nat Pagle's Extreme Angler FC-5000  20
"25978" , -- Seth's Graphite Fishing Pole        20
"6366"  , -- Darkwood Fishing Pole               15
"84660" , -- Pandaren Fishing Pole               10
"46337" , -- Staats' Fishing Pole                 3                       Alliance
"12225" , -- Blump Family Fishing Pole            3
"6365"  , -- Strong Fishing Pole                  5
"120163", -- Thruk's Fishing Rod                  3
"6256"  , -- Fishing Pole                         0
}

-- define a fishing hats table sorted by arbitrary 'best' order
local fishHats = {
-- ID        Name                            +Skill  +Other          
"118380", -- Hightfish Cap                     100
"118393", -- Tentacled Hat                     100   
"117405", -- Nat's Drinking Hat                 10   Lure +150
"88710" , -- Nat's Hat                           5   Lure +150
"33820" , -- Weather-Beaten Fishing Hat          5   Lure +75
"93732" , -- Darkmoon Fishing Cap                5   Summon Debris Pool during Darkmoon Faire
"19972" , -- Lucky Fishing Hat                   5   +15 STA
}

--[[
Function to extract the ItemID from the item link
  Parameter passed is the ItemLink.
  Uses lua string.match to obtain the item:xxxx string from the link
  Returns the itemID we are searching for (i.e. 118381 for the Ephemeral Fishing Pole)
  Called by CheckForUpgradesFromSomething
--]]
local function fspGetItemID(link)
  if link then
    return string.match(link, "item:(%-?%d+):")
  end
end

-- create the addon frame and register the ADDON_LOADED event
local fsp = CreateFrame("Frame", nil, UIParent)
fsp:RegisterEvent("ADDON_LOADED")

-------------------------------------------------------------------------------
-- FUNCTIONS
-------------------------------------------------------------------------------

--[[
Function to search the inventory for an itemID and return the link to the item. 
  Parameter passed is the string of the ItemID being searched (i.e. 118381 for the 
    Ephemeral Fishing Pole)
  Uses lua string.find() method to locate an item:xxxx string within the returned
    string (link) from the GetContainerItemLink(container,slot) API function.
  Returns a string with the in-game link to the upgraded item.
  Called by Called by CheckForUpgradesFromSomething and CheckForUpgradesFromNothing
]]--
function fsp:SearchMyInventory(itemID)
  -- format the itemID with the string within the link
  local strItemID = "item:"..itemID..":" 
  -- loop over all containers by the containerID index
  for containerID = 0, 4 do 
    -- search the each of the slots within this containerID for the requested item
    for containerSlotID = 1, GetContainerNumSlots(containerID) do 
      -- get the link for this slotID
      local strResult = GetContainerItemLink(containerID, containerSlotID)
      -- is this the droid we're looking for?
      if strResult and strResult:find(strItemID) then
        -- success!
        return strResult
      end
    end
  end
end

--[[
Function to iterate over an upgrade table when something is already equipped.  
  Parameters passed are
    1) the string of the currently equipped ItemLink for the referenced slot (Main Hand or Head)
    2) the table to search (i.e. poles or hats)
  Calls GetItemID to extract the current ItemID from the current ItemLink
  Checks if the current item is the same as the best item
    if yes, stops checking.
    if no, calls SearchMyInventory with the current table value
    if SearchMyInventory returns an ItemLink then call EquipItemByName() API function to equip the upgrade
    if SearchMyInventory fails to return an ItemLink, grab the next table item and repeat.
  Called by CheckForUpgrades()
--]]
function fsp:CheckForUpgradesFromSomething(currentItemLink, theTable)
  for key, betterItemID in ipairs(theTable) do
    -- extract the itemID from the passed Link
    local currentItemID = fspGetItemID(currentItemLink)
    -- check if we have already equipped the 'best'
    if currentItemID == betterItemID then 
      -- already using the best so look no further
      break
    -- check inventory for a superior item
    else 
      local betterItemLink = self:SearchMyInventory(betterItemID)
      if betterItemLink then
        -- equip the better item
        EquipItemByName(betterItemLink)
        -- output a chat frame message to inform the user what we did
        print("FishingShack|cffff00ffPro|r: " .. L["UPGRADE!"] .. " " .. currentItemLink .. " " .. L["replaced by"] .. " " .. betterItemLink .. "!")
        -- found a superior item so skip the rest
        break 
      end
    end
  end 
end

--[[
Function to iterate over an upgrade table when nothing is currently equipped
  Parameters passed is 
    1) the table to search (i.e. poles or hats)
  Calls SearchMyInventory with the current table value
    if SearchMyInventory returns an ItemLink then call EquipItemByName() API function to equip the upgrade
    if SearchMyInventory fails to return an ItemLink, grab the next table item and repeat.
  Called by CheckForUpgrades()
--]]
function fsp:CheckForUpgradesFromNothing(theTable)
  for key, betterItemID in ipairs(theTable) do
    local betterItemLink = self:SearchMyInventory(betterItemID)
    if betterItemLink then
      EquipItemByName(betterItemLink)
      -- output a chat frame message to inform the user what we did
      print("FishingShack|cffff00ffPro|r: " .. L["UPGRADE!"] .. " " .. L["Now using"] .. betterItemLink .. "!")
      break -- found a superior item so skip the rest
    end
  end 
end


-- Function to check for item upgrades
function fsp:CheckForUpgrades()
	-- POLES
	local poleLink = GetInventoryItemLink("player", 16)

	-- is our current pole baited and is our pref. set to replace anyway?
	local gotBait = GetWeaponEnchantInfo()
	if gotBait then
		if REPLACE_LURE then
			self:CheckForUpgradesFromSomething(poleLink, fishPoles)
		end
	else
		self:CheckForUpgradesFromSomething(poleLink, fishPoles)
	end

	-- HATS
	local hatLink = GetInventoryItemLink("player", 1)
	if hatLink == nil then
		self:CheckForUpgradesFromNothing(fishHats)
	else 
		self:CheckForUpgradesFromSomething(hatLink, fishHats)
	end
	fsp:Hide()
end

-------------------------------------------------------------------------------
-- EVENT HANDLER
-------------------------------------------------------------------------------
fsp:SetScript("OnEvent", function(self, event, ...)
	if ENABLE_FSP or InCombatLockdown() then
		if event == "ADDON_LOADED" and ... == addon then
			-- our saved variable is ready. If none present, initialize it as true
			if REPLACE_LURE == nil then
				REPLACE_LURE = true
			end
			-- we've loaded, who cares about the rest?
			self:UnregisterEvent("ADDON_LOADED") 
			-- now that we're loaded, register other events
			self:RegisterEvent("PLAYER_ENTERING_WORLD")
			
		elseif event == "PLAYER_ENTERING_WORLD" then
			-- log our status to chat
			print("FishingShack|cffff00ffPro|r: is now loaded. Use /fishingshackpro or /fsp for additional options.")
			if REPLACE_LURE then
				print("FishingShack|cffff00ffPro|r: " .. L["replace poles with active bait applied"] .. ": " .. L["ON"])
			else
				print("FishingShack|cffff00ffPro|r: " .. L["replace poles with active bait applied"] .. ": " .. L["OFF"])
			end
			
			-- double check that type is registered because no friggin clue why the variable wasnt being assigned
			if not TYPE_FISHING_POLES then 
				TYPE_FISHING_POLES = select(7, GetItemInfo(6256))
			end
			
			self:UnregisterEvent("PLAYER_ENTERING_WORLD")
			self:RegisterEvent("EQUIPMENT_SWAP_PENDING")
			self:RegisterEvent("EQUIPMENT_SWAP_FINISHED")
			self:RegisterEvent("UNIT_INVENTORY_CHANGED", "player")
			
		-- ignore during equipment manager swaps (if enabled)
		elseif event == "EQUIPMENT_SWAP_PENDING" then
			self:UnregisterEvent("UNIT_INVENTORY_CHANGED") 
			
		-- restore after equipment manager swap (if enabled)
		elseif event == "EQUIPMENT_SWAP_FINISHED" then
			self:RegisterEvent("UNIT_INVENTORY_CHANGED", "player") 

		-- inventory changed, let's check
		elseif event == "UNIT_INVENTORY_CHANGED" then
			-- ensure the constant is valid during the event handler
			if TYPE_FISHING_POLES then
				-- Let's get to work if we are in fact fishing
				if IsEquippedItemType(TYPE_FISHING_POLES) then
					fsp:CheckForUpgrades()
				end
			end
		end
	end	
end)

-------------------------------------------------------------------------------
-- SLASH COMMANDS
-------------------------------------------------------------------------------
-- command table
local fspSlashCmdTbl = {
	["enable"] = function(enableYN)
		if enableYN == "y" then
			ENABLE_FSP = true
			-- start monitoring UNIT_INVENTORY_CHANGED for this player
			fsp:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", "player")
			print("FishingShack|cffff00ffPro|r: " .. L["enable the addon"] .. ": " .. L["ON"])
		elseif enableYN == "n" then
			ENABLE_FSP = false
			-- stop monitoring UNIT_INVENTORY_CHANGED for this player
			fsp:UnregisterEvent("UNIT_INVENTORY_CHANGED")
			print("FishingShack|cffff00ffPro|r: " .. L["enable the addon"] .. ": " .. L["OFF"])
		else
			self:SlashCommandTable("help", fspSlashCmdTbl)
		end
	end,
	["lure"] = function(lureYN)
		if lureYN == "y" then
			REPLACE_LURE = true
			print("FishingShack|cffff00ffPro|r: " .. L["replace poles with active bait applied"] .. ": " .. L["ON"])
		elseif lureYN == "n" then
			REPLACE_LURE = false
			print("FishingShack|cffff00ffPro|r: " .. L["replace poles with active bait applied"] .. ": " .. L["OFF"])
		else
			self:SlashCommandTable("help", fspSlashCmdTbl)
		end
	end,
	["help"] = L["commands"] .. ": \n"
		.. "enable Y|N -- " .. L["enable the addon"] .. "? " .. L["Yes"] .. "|" .. L["No"] .. "\n"
		.. "lure Y|N -- " .. L["replace poles with active bait applied"] .. "? " .. L["Yes"] .. "|" .. L["No"]
}

-- command function
function fsp:SlashCommandTable(msg, tbl)
	local cmd, params = string.split(" ", msg, 2)
	local entry = fspSlashCmdTbl[cmd:lower()]
	local cmdT = type(entry)

	if cmdT == "function" and params ~= nil then
		entry(params:lower())
	elseif cmdT == "string" then
		print("FishingShack|cffff00ffPro|r: " .. entry)
	elseif msg ~= "help" then
		self:SlashCommandTable("help", fspSlashCmdTbl)
	end 
end

SLASH_FISHINGSHACKPRO1 = "/fishingshackpro"
SLASH_FISHINGSHACKPRO2 = "/fsp"
SlashCmdList["FISHINGSHACKPRO"] = function(msg)
  fsp:SlashCommandTable(msg, fspSlashCmdTbl)
end