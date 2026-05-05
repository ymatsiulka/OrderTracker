local AddonName, OrderTracker = ...;
OrderTracker.LinkHelper = {};
local LinkHelper = OrderTracker.LinkHelper

function LinkHelper:ParseItemLink(msg)
    local name = msg:match("%[([^%]]+)%]")
    return {
        name = name
    }
end
