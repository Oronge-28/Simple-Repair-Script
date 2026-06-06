Config = {}

-- Name des Items im Inventar
Config.Item = 'repairkit'

-- Dauer der Reparatur in Millisekunden (z. B. 10000 = 10 Sekunden)
Config.RepairTime = 10000

-- Progress-Anzeige von ox_lib. Optionen: 'circle' (Kreis) oder 'bar' (Balken)
Config.ProgressStyle = 'circle'
Config.ProgressLabel = 'Fahrzeug wird repariert...'

-- Soll die Motorhaube des Fahrzeugs während der Reparatur geöffnet werden? (true/false)
Config.OpenHood = true

-- Muss das Fahrzeug beschädigt sein, um das Reparaturkit zu benutzen?
-- Wenn true, kann ein vollkommen intaktes Fahrzeug nicht repariert werden (spart Items).
Config.NeedVehicleDamaged = true

-- Soll das Item nach erfolgreicher Reparatur verbraucht werden? (true/false)
Config.RemoveItemSuccess = true

-- Wahrscheinlichkeit in Prozent, dass das Reparaturkit verbraucht wird (1 bis 100)
-- 100 = Wird immer verbraucht, 50 = 50% Chance, dass es verbraucht wird.
Config.RemoveItemChance = 100

-- Animations-Einstellungen für die Reparatur
Config.Anim = {
    dict = 'mini@repair',
    name = 'fixing_a_ped',
    flag = 1 -- Loop-Animation
}

-- Benachrichtigungs-Wrapper (Custom Notify)
-- Hier kannst du dein eigenes Notify-System eintragen (z.B. okokNotify, mythic_notify, etc.)
Config.Notify = {
    Client = function(title, description, type)
        -- Client-seitige Benachrichtigung
        -- Standard: ox_lib notify. Mögliche Typen: 'success', 'info', 'warning', 'error'
        lib.notify({
            title = title,
            description = description,
            type = type,
            position = 'top'
        })
        
        -- Beispiel für okokNotify (Client):
        -- exports['okokNotify']:Alert(title, description, 5000, type)
    end,

    Server = function(source, title, description, type)
        -- Server-seitige Benachrichtigung (sendet an eine bestimmte Spieler-ID)
        -- Standard: ox_lib notify via Client Event
        TriggerClientEvent('ox_lib:notify', source, {
            title = title,
            description = description,
            type = type,
            position = 'top'
        })

        -- Beispiel für okokNotify (Server):
        -- TriggerClientEvent('okokNotify:Alert', source, title, description, 5000, type)
    end
}

-- Sprachübersetzungen / Benachrichtigungstexte
Config.Locales = {
    ['no_vehicle_near'] = 'Kein Fahrzeug in der Nähe!',
    ['vehicle_already_fine'] = 'Dieses Fahrzeug hat keinen Schaden!',
    ['repair_success'] = 'Fahrzeug erfolgreich repariert!',
    ['repair_canceled'] = 'Reparatur abgebrochen!',
    ['not_in_vehicle'] = 'Du musst außerhalb des Fahrzeugs sein, um es zu reparieren!',
    ['item_removed'] = 'Dein Reparaturkit wurde aufgebraucht.'
}
