local AddonName, OrderTracker = ...;
OrderTracker.CharacterProfessionsScanner = {};
local CharacterProfessionsScanner = OrderTracker.CharacterProfessionsScanner

-- Scan recipes using modern API
local function ScanRecipesModern(skillLineID, professionData)
    local wasOpen = C_TradeSkillUI.IsTradeSkillReady()
    if not wasOpen then
        C_TradeSkillUI.OpenTradeSkill(skillLineID)
    end

    C_Timer.After(0.1, function()
        local recipes = C_TradeSkillUI.GetAllRecipeIDs()
        if recipes then
            for _, recipeID in ipairs(recipes) do
                local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
                print("Recipe", professionData.professionID, skillLineID, recipeInfo.categoryID)
                local link = C_TradeSkillUI.GetRecipeItemLink(recipeID)
                professionData.recipes[recipeID] = {
                    recipeID = recipeID,
                    name = recipeInfo.name,
                    link = link
                }
            end
        end

        if not wasOpen then
            C_TradeSkillUI.CloseTradeSkill()
        end
    end)
end

function CharacterProfessionsScanner:ScanByKey(characterKey)
    -- Scan Character
    for charKey, charData in pairs(OrderTrackerDB.Characters) do
        print("Character:", charKey, "Class:", charData.class or "Unknown")
    end

    local skillLineIds = C_TradeSkillUI.GetAllProfessionTradeSkillLines()

    for _, skillLineId in ipairs(skillLineIds) do
        local skillLineInfo = C_TradeSkillUI.GetProfessionInfoBySkillLineID(skillLineId)

        OrderTrackerDB.Characters[characterKey].professions[skillLineId] = {
            professionID = skillLineInfo.professionID,
            name = skillLineInfo.professionName,
            skillLevel = skillLineInfo.skillLevel,
            maxSkillLevel = skillLineInfo.skillModifier,
            skillLineID = skillLineId,
            recipes = {}
        }

        ScanRecipesModern(skillLineId, OrderTrackerDB.Characters[characterKey].professions[skillLineId])
    end
end
