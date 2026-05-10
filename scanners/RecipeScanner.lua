local AddonName, OrderTracker = ...;
OrderTracker.RecipeScanner = {};
local RecipeScanner = OrderTracker.RecipeScanner

function RecipeScanner:Scan(profession)
    local wasOpen = C_TradeSkillUI.IsTradeSkillReady()
    if not wasOpen then
        C_TradeSkillUI.OpenTradeSkill(profession.id)
    end

    C_Timer.After(0.1, function()
        local recipes = C_TradeSkillUI.GetAllRecipeIDs()
        if recipes then
            for _, recipeID in ipairs(recipes) do
                local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
                print("Recipe", profession.id, profession.id, recipeInfo.categoryID, recipeID)
                local link = C_TradeSkillUI.GetRecipeItemLink(recipeID)
                profession.recipes[recipeID] = {
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
