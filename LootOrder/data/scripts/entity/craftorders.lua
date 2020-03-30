-- LootOrder
-- by Kevin Gravier (MrKMG)
-- MIT License 2019

CraftOrders.registerModdedCraftOrder(OrderType.Loot, {
    title = "Loot",
    callback = "onUserLootOrder"
})

function CraftOrders.onUserLootOrder()
    if onClient() then
        invokeServerFunction("onUserLootOrder")
        ScriptUI():stopInteraction()
        return
    end

    Entity():invokeFunction("data/scripts/entity/orderchain.lua", "clearAllOrders")
    Entity():invokeFunction("data/scripts/entity/orderchain.lua", "addLootOrder", true)
    Entity():invokeFunction("data/scripts/entity/orderchain.lua", "runOrders")
end
callable(CraftOrders, "onUserLootOrder")


function CraftOrders.loot()
    if onClient() then
        invokeServerFunction("loot")
        ScriptUI():stopInteraction()
        return
    end

    if checkCaptain() then
        CraftOrders.removeSpecialOrders()
        Entity():addScriptOnce("ai/loot.lua")
        return true
    end
end
callable(CraftOrders, "loot")
