-- ===== CONFIG =====
local AddonName, OrderTracker = ...;

-- Initialize saved variables (global table that WoW persists)
OrderTrackerDB = OrderTrackerDB or {}
OrderTrackerDB.Characters = OrderTrackerDB.Characters or {}
OrderTrackerDB.Orders = OrderTrackerDB.Orders or {}

-- Get current character key
function GetCharacterKey()
    local playerName = UnitName("player")
    local realmName = GetRealmName()
    return playerName .. "-" .. realmName
end

function ScanCharacter(characterKey)
    if not OrderTrackerDB.Characters[characterKey] then
        OrderTrackerDB.Characters[characterKey] = {
            name = UnitName("player"),
            realm = GetRealmName(),
            class = select(2, UnitClass("player")),
            professions = {}
        }
    end
end

-- Scan recipes using modern API
function ScanRecipesModern(skillLineID, professionData)
    local wasOpen = C_TradeSkillUI.IsTradeSkillReady()
    if not wasOpen then
        C_TradeSkillUI.OpenTradeSkill(skillLineID)
    end

    C_Timer.After(0.1, function()
        local recipes = C_TradeSkillUI.GetAllRecipeIDs()
        if recipes then
            for _, recipeID in ipairs(recipes) do
                local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
                local link = C_TradeSkillUI.GetRecipeItemLink(recipeID)
                if (string.find(recipeInfo.name, "амулет")) then
                    -- print("Skipping recipe:", recipeInfo.name, link, professionData.name)
                    professionData.recipes[recipeID] = {
                        recipeID = recipeID,
                        name = recipeInfo.name,
                        link = link
                    }
                    return
                end

            end
        end

        if not wasOpen then
            C_TradeSkillUI.CloseTradeSkill()
        end
    end)
end

function SearchRecipeInAllCharacters(searchCriteria, author)
    print("Scan Recipe in all characters for:", searchCriteria)
    for charKey, charData in pairs(OrderTrackerDB.Characters) do
        for profKey, profData in pairs(charData.professions) do
            for recipeID, recipeData in pairs(profData.recipes) do
                if string.find(recipeData.name, "амулет") then
                    print("Skipping recipe:", recipeData.name, profData.name)
                end
                -- if string.find(string.lower(searchCriteria), string.lower(recipeData.hyperlink)) then
                --     print("Found hyperlink", searchCriteria, "in", charKey, "profession", profData.name)
                --     local itemLinkName = ParseItemLink(searchCriteria)

                --     -- Add to orders if author provided
                --     local order = {
                --         itemLinkName = recipeData.name,
                --         itemLink = recipeData.hyperlink,
                --         author = author,
                --         message = searchCriteria,
                --         crafterCharacter = charKey, -- Add crafter character name
                --         status = "NEW",
                --         timestamp = time()
                --     }
                --     -- table.insert(OrderTrackerDB.Orders, order)
                --     -- ShowOrderUI(order)
                --     return
                -- end
                if string.find(string.lower(searchCriteria), string.lower(recipeData.name), 1, true) then
                    print("Found", searchCriteria, "in", charKey, "profession", profData.name)
                    local itemLinkName = LinkHelper:ParseItemLink(searchCriteria)

                    -- Add to orders if author provided
                    local order = {
                        itemLinkName = recipeData.name,
                        itemLink = recipeData.hyperlink,
                        author = author,
                        message = searchCriteria,
                        crafterCharacter = charKey, -- Add crafter character name
                        status = "NEW",
                        timestamp = time()
                    }
                    -- table.insert(OrderTrackerDB.Orders, order)
                    -- ShowOrderUI(order)
                    return
                end

            end
        end
    end
end

function ScanCharacterProfessions()
    -- Scan Character
    local characterKey = GetCharacterKey()
    ScanCharacter(characterKey)
    for charKey, charData in pairs(OrderTrackerDB.Characters) do
        print("Character:", charKey, "Class:", charData.class or "Unknown")
    end
    local skillLineIds = C_TradeSkillUI.GetAllProfessionTradeSkillLines()

    for _, skillLineId in ipairs(skillLineIds) do
        local skillLineInfo = C_TradeSkillUI.GetProfessionInfoBySkillLineID(skillLineId)

        OrderTrackerDB.Characters[characterKey].professions[skillLineId] = {
            name = skillLineInfo.professionName,
            skillLevel = skillLineInfo.skillLevel,
            maxSkillLevel = skillLineInfo.skillModifier,
            skillLineID = skillLineId,
            recipes = {}
        }
        
        ScanRecipesModern(skillLineId, OrderTrackerDB.Characters[characterKey].professions[skillLineId])
    end
end

ScanCharacterProfessions()

-- Subscribe on chat messages with delay to ensure data is loaded
C_Timer.After(1.0, function()
    local chatListener = CreateFrame("Frame")
    local chatListenerEvents = {"CHAT_MSG_CHANNEL", "CHAT_MSG_SAY"}
    for _, e in ipairs(chatListenerEvents) do
        chatListener:RegisterEvent(e)
    end

    chatListener:SetScript("OnEvent", function(self, event, msg, author, _, _, _, _, _, _, _, _, _, guid)
        print("Channel msg:", msg, "from", author)
        SearchRecipeInAllCharacters(msg, author)
    end)

    print("Chat listener initialized after 1 second delay")
end)

