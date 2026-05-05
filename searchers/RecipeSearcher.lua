local AddonName, OrderTracker = ...;
OrderTracker.RecipeSearcher = {};
local RecipeSearcher = OrderTracker.RecipeSearcher

function RecipeSearcher:SearchRecipeInAllCharacters(message, senderName)
    print("Scan Recipe in all characters for:", message)
    for charKey, charData in pairs(OrderTrackerDB.Characters) do
        for profKey, profData in pairs(charData.professions) do
            for recipeID, recipeData in pairs(profData.recipes) do
                local itemLinkName = OrderTracker.LinkHelper:ParseItemLink(message)

                if string.find(string.lower(message), string.lower(recipeData.name), 1, true) then
                    print("Found", message, "in", charKey, "profession", profData.name)
                    local itemLinkName = OrderTracker.LinkHelper:ParseItemLink(message)

                    -- Add to orders if author provided
                    local order = {
                        itemLinkName = recipeData.name,
                        itemLink = recipeData.hyperlink,
                        senderName = senderName,
                        message = message,
                        crafterCharacter = charKey, -- Add crafter character name
                        status = "NEW",
                        timestamp = time()
                    }
                    
                    return
                end

            end
        end
    end
end
