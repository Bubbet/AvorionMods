package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"

include ("stringutility")
include ("sync")
include ("extutils")
local TradingUtility = include ("tradingutility")

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace TradeBeacon
TradeBeacon = {}
local self = TradeBeacon
self.data = {time = 24 * 60 * 60}

defineSyncFunction("data", self)

function TradeBeacon.getUpdateInterval()
    return 10
end

function TradeBeacon.interactionPossible()
    return true
end

function TradeBeacon.initialize()
    if onClient() then
        self.sync()
    else
        TradeBeacon.registerWithPlayer()
    end
end

function TradeBeacon.initUI()
    ScriptUI():registerInteraction("Close"%_t, "")
end

function TradeBeacon.registerWithPlayer()
    local entityId = Entity().index.string
    local x, y = Sector():getCoordinates()
    local tradeData = TradeBeacon.getTradeData()
    local script = "tradebeacon.lua"
    Player(getParentFaction().index):invokeFunction(script, "registerTradeBeacon", x, y, entityId, tradeData)
end

function TradeBeacon.unregisterWithPlayer()
    local entityId = Entity().index.string
    local script = "tradebeacon.lua"
    Player(getParentFaction().index):invokeFunction(script, "deregisterTradeBeacon", entityId)
end

function TradeBeacon.updateServer(timeStep)

    self.data.time = self.data.time - timeStep

    local player = Player(getParentFaction().index)
    local entity = Entity()

    if entity == nil or player == nil then
        print ("Missing entity or player in entity/tradebeacon updateServer")
        return
    end

    local x, y = Sector():getCoordinates()
    if self.data.time <= 0 then
        getParentFaction():sendChatMessage("Trade Beacon"%_T, ChatMessageType.Normal, [[Your trade beacon in sector \s(%1%:%2%) burnt out!]]%_T, x, y)
        getParentFaction():sendChatMessage("Trade Beacon"%_T, ChatMessageType.Warning, [[Your trade beacon in sector \s(%1%:%2%) burnt out!]]%_T, x, y)
        TradeBeacon.unregisterWithPlayer()
        entity:destroy(entity.index, DamageType.Decay)
        terminate()
    else
        TradeBeacon.registerWithPlayer()
    end
end

function TradeBeacon.updateClient(timeStep)
    self.data.time = self.data.time - timeStep
    self.sync()
end


function TradeBeacon.secure()
    return self.data
end

function TradeBeacon.restore(data)
    self.data = data
end

function TradeBeacon.onSync()

end

function TradeBeacon.serializeGood(good)
    return {
        name = good.name,
        plural = good.plural,
        description = good.description,
        icon = good.icon,
        price = good.price,
        size = good.size,
    }
end

function TradeBeacon.serializeItem(item)
    item.good = TradeBeacon.serializeGood(item.good)
    item.coords = {x = item.coords.x, y = item.coords.y}
    item.stationIndex = item.stationIndex.string
end

function TradeBeacon.getTradeData()
    local sellable, buyable = TradingUtility.detectBuyableAndSellableGoods()

    for _, d in ipairs(sellable) do
        TradeBeacon.serializeItem(d)
    end
    for _, d in ipairs(buyable) do
        TradeBeacon.serializeItem(d)
    end
    return serialize({sellable = sellable, buyable = buyable})
end
