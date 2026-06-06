local ESX = exports["es_extended"]:getSharedObject()
local isRepairing = false

-- Hilfsfunktion: Finde das nächste Fahrzeug im Umkreis von 3.0 Metern
local function GetClosestVehicle()
    local ped = cache.ped or PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    -- Verwendung der optimierten ox_lib Funktion
    local vehicle, vehicleCoords = lib.getClosestVehicle(coords, 3.0, false)
    return vehicle, vehicleCoords
end

-- Hilfsfunktion: Überprüft, ob das Fahrzeug repariert werden muss
local function IsVehicleDamaged(vehicle)
    if not Config.NeedVehicleDamaged then return true end

    -- Check Motor- und Karosserieschaden
    if GetVehicleEngineHealth(vehicle) < 1000.0 or GetVehicleBodyHealth(vehicle) < 1000.0 then
        return true
    end

    -- Check ob Reifen platt sind (0 bis 7 sind die Standard-Reifen-IDs)
    for i = 0, 7 do
        if IsVehicleTyreBurst(vehicle, i, false) or IsVehicleTyreBurst(vehicle, i, true) then
            return true
        end
    end

    return false
end

-- Event, das vom Server ausgelöst wird, wenn der Spieler das Reparaturkit benutzt
RegisterNetEvent('oro_repair:attemptRepair', function()
    if isRepairing then return end

    local ped = PlayerPedId()

    -- Check ob der Spieler in einem Fahrzeug sitzt
    if IsPedInAnyVehicle(ped, false) then
        Config.Notify.Client('Fehler', Config.Locales['not_in_vehicle'], 'error')
        return
    end

    -- Finde das nächste Fahrzeug
    local vehicle, vehicleCoords = GetClosestVehicle()
    if not vehicle or not DoesEntityExist(vehicle) then
        Config.Notify.Client('Fehler', Config.Locales['no_vehicle_near'], 'error')
        return
    end

    -- Überprüfe, ob das Fahrzeug überhaupt repariert werden muss
    if not IsVehicleDamaged(vehicle) then
        Config.Notify.Client('Info', Config.Locales['vehicle_already_fine'], 'info')
        return
    end

    isRepairing = true

    -- Ped zum Fahrzeug ausrichten
    TaskTurnPedToFaceEntity(ped, vehicle, 1000)
    Wait(1000)

    -- Motorhaube öffnen (falls aktiviert und vorhanden)
    local hasHood = DoesVehicleHaveDoor(vehicle, 4)
    if Config.OpenHood and hasHood then
        SetVehicleDoorOpen(vehicle, 4, false, false)
    end

    -- Progress-Einstellungen vorbereiten
    local progressParams = {
        duration = Config.RepairTime,
        label = Config.ProgressLabel,
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
        },
        anim = {
            dict = Config.Anim.dict,
            clip = Config.Anim.name,
            flag = Config.Anim.flag,
        }
    }

    -- Progress-Anzeige starten (Balken oder Kreis je nach Config)
    local success = false
    if Config.ProgressStyle == 'circle' then
        success = lib.progressCircle(progressParams)
    else
        success = lib.progressBar(progressParams)
    end

    -- Motorhaube wieder schließen (falls geöffnet)
    if Config.OpenHood and hasHood then
        SetVehicleDoorShut(vehicle, 4, false)
    end

    -- Stop aller Animationen nach Progress-Ende
    ClearPedTasks(ped)

    if success then
        -- Hole die Netzwerk-ID des Fahrzeugs, um sie an den Server zu senden
        local netId = NetworkGetNetworkIdFromEntity(vehicle)
        TriggerServerEvent('oro_repair:completeRepair', netId)
    else
        Config.Notify.Client('Info', Config.Locales['repair_canceled'], 'info')
    end

    isRepairing = false
end)

-- Event zur Ausführung der tatsächlichen Fahrzeugreparatur auf Clientseite
RegisterNetEvent('oro_repair:applyRepair', function(netId)
    if not NetworkDoesNetworkIdExist(netId) then return end
    
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not DoesEntityExist(vehicle) then return end

    -- Netzwerkbesitz prüfen/anfordern, um Synchronisationsprobleme zu vermeiden
    local attempts = 0
    while not NetworkHasControlOfEntity(vehicle) and attempts < 10 do
        NetworkRequestControlOfEntity(vehicle)
        Wait(50)
        attempts = attempts + 1
    end

    -- Komplette Reparatur durchführen
    SetVehicleFixed(vehicle)
    SetVehicleDeformationFixed(vehicle)
    SetVehicleDirtLevel(vehicle, 0.0)

    -- Explizites Wiederherstellen aller Reifen
    for i = 0, 7 do
        SetVehicleTyreFixed(vehicle, i)
    end
end)
