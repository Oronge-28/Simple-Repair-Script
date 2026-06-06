local ESX = exports["es_extended"]:getSharedObject()

-- Registrierung des benutzbaren Items
ESX.RegisterUsableItem(Config.Item, function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    -- Trigger client-seitige Abfrage und Reparatur-Ablauf
    TriggerClientEvent('oro_repair:attemptRepair', source)
end)

-- Server-seitiges Event zur Verifizierung und Ausführung
RegisterNetEvent('oro_repair:completeRepair', function(netId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    -- Hole Item aus dem Inventar und ermittle die Menge
    local item = xPlayer.getInventoryItem(Config.Item)
    local count = 0

    if item then
        if type(item) == 'table' then
            count = item.count or item.amount or 0
        elseif type(item) == 'number' then
            count = item
        end
    end

    -- Sicherheits-Check: Hat der Spieler wirklich das Item?
    if count <= 0 then
        print(("[SECURITY] Spieler %s (ID: %s) hat versucht, ein Fahrzeug ohne ein Reparaturkit (%s) zu reparieren!"):format(xPlayer.getName(), src, Config.Item))
        return
    end

    -- Entferne das Item (falls in Config aktiviert)
    local itemRemoved = false
    if Config.RemoveItemSuccess then
        local roll = math.random(1, 100)
        if roll <= Config.RemoveItemChance then
            xPlayer.removeInventoryItem(Config.Item, 1)
            itemRemoved = true
        end
    end

    -- Führe die Reparatur für alle Clients synchronisiert aus (getriggert auf dem Initiator)
    TriggerClientEvent('oro_repair:applyRepair', src, netId)

    -- Benachrichtigungen senden
    Config.Notify.Server(src, 'Erfolg', Config.Locales['repair_success'], 'success')
    
    if itemRemoved then
        Config.Notify.Server(src, 'Info', Config.Locales['item_removed'], 'info')
    end
end)
