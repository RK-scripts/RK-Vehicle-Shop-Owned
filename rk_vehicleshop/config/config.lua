Config = {}

Config.Job = 'cardealer' -- Nome del lavoro
Config.Society = 'society_cardealer' -- Nome della società in addon_account_data
Config.Grade = 3 -- Grado minimo per accedere al menù boss

-- Definisci le coordinate del boss menu
Config.BossMenuCoords = vector3(-31.9754, -1114.0748, 26.4223)

Config.SpawnCatalog = { -- posizione spawn catalogo
    Pos = vector3(-45.5621, -1095.7419, 26.4224),
    Heading = 118.64
}

Config.Katalog = { -- posizione catalogo
    Pos = vector3(-56.0062, -1096.5282, 26.4223),
    Heading = 177.28
}

Config.Cardealer = { -- posizione menù vendita veicoli
    Pos = vector3(-31.3394, -1106.5017, 26.4221),
    Heading = 177.28
}

Config.Spots = { -- Posizioni degli spot per i veicoli
    {name = "Spot 1", coords = vector3(-48.6976, -1100.3102, 26.4223), heading = 90.0},
    {name = "Spot 2", coords = vector3(-40.4829, -1096.9535, 26.4224), heading = 90.0},
    {name = "Spot 3", coords = vector3(-46.8557, -1093.0936, 26.4224), heading = 90.0}
    -- Aggiungi più spot se necessario
}

Config.Marker = {
    Type = 2, -- Tipo di marker (cambia numero per modificare lo stile)
    Size = {x = 1.0, y = 1.0, z = 1.0}, -- Dimensioni del marker
    Color = {r = 255, g = 0, b = 0, a = 150} -- Colore del marker (RGBA)
}

Config.Blip = {
    Title = 'Concessionario',
    Type = 225, -- Tipo di blip
    Color = 1, -- Colore del blip
    Scale = 1.0 -- Grandezza del blip
}

-- Posizione del Menù per l'interazione con gli spot
Config.SpotsCar = vector3(-54.4794, -1097.0516, 26.4223)

-- Configurazione dell'interazione
Config.InteractionType = 'ox_target' -- 'ox_target' or 'ox_lib'
Config.DrawDistance = 5.0

Config.NotificationType = 'ox_lib' -- 'ox_lib', or 'es_extended' 

Config.WebhookURL = 'https://discord.com/api/webhooks/1259429467575550052/XNtwVvCvog_vMrrwPdNmjMKZu3yWMDc209wPTbMLEOtaZT_OTMQFoSkLPQTO5ZlryTKv' -- Inserisci qui l'URL del webhook

-- Configurazione delle categorie e dei veicoli
Config.Categories = {
    {name = 'compacts', label = 'Compacts'},
    {name = 'coupes', label = 'Coupes'},
    {name = 'muscle', label = 'Muscle'},
    {name = 'suvs', label = 'SUVs'},
    {name = 'sedans', label = 'Sedans'},
    {name = 'sports', label = 'Sports'},
    {name = 'sport_classic', label = 'Sport Classic'},
    {name = 'super', label = 'Super'},
    {name = 'vans', label = 'Vans'}
    -- Aggiungi più categorie se necessario
    
}

Config.Vehicles = {
    {name = 'Blista', model = 'blista', price = 25000, category = 'compacts'},
    {name = 'Dilettante', model = 'dilettante', price = 23000, category = 'compacts'},
    {name = 'Cognoscenti Cabrio', model = 'cogcabrio', price = 200000, category = 'coupes'},
    {name = 'F620', model = 'f620', price = 180000, category = 'coupes'},
    {name = 'Dominator', model = 'dominator', price = 350000, category = 'muscle'},
    {name = 'Gauntlet', model = 'gauntlet', price = 300000, category = 'muscle'},
    {name = 'Baller', model = 'baller', price = 150000, category = 'suvs'},
    {name = 'Landstalker', model = 'landstalker', price = 130000, category = 'suvs'},
    {name = 'Asea', model = 'asea', price = 10000, category = 'sedans'},
    {name = 'Asterope', model = 'asterope', price = 15000, category = 'sedans'},
    {name = 'Adder', model = 'adder', price = 500000, category = 'sports'},
    {name = 'Entity XF', model = 'entityxf', price = 700000, category = 'sports'},
    {name = 'Z-Type', model = 'ztype', price = 900000, category = 'sport_classic'},
    {name = 'Stinger GT', model = 'stingergt', price = 750000, category = 'sport_classic'},
    {name = 'T20', model = 't20', price = 1200000, category = 'super'},
    {name = 'Reaper', model = 'reaper', price = 1500000, category = 'super'},
    {name = 'Burrito', model = 'burrito', price = 35000, category = 'vans'},
    {name = 'Minivan', model = 'minivan', price = 25000, category = 'vans'}
    -- Aggiungi più veicoli se necessario
}

Config.SocietyDiscount = 10 -- Percentuale di sconto per la società

Config.TestDrive = {
    Pos = vector3(-30.4798, -1089.4541, 26.4221), -- Coordinate di spawn per il test drive
    Heading = 0.0, -- Heading per il test drive
    Duration = 30 -- Durata del test drive in secondi
}

Config.TeleportCoords = vector3(-30.4798, -1089.4541, 26.4221) -- Coordinate di teletrasporto per il veicolo acquistato

Config.NoPermissionMessage = 'Non hai i permessi per accedere a questo menu'

Config.Locale = { -- Traduzioni ITA
    --carpoint
    carpoint_catalog = 'Premi [E] per aprire il menu spot',
    spot_vehicle = 'Scegli lo spot',
    remove_spot = 'Veicolo rimosso dallo spot',
    category_spot = 'Scegli una Categoria',
    novehicle_spot = 'Nessun veicolo disponibile in questa categoria.',
    select_vehicle = 'Seleziona un Veicolo',
    no_model = 'Modello del veicolo non valido.',
    spawn_vehicle = 'Veicolo spawnato con successo nello spot selezionato.',
    no_spawn = 'Impossibile spawnare il veicolo.',
    fixed_spot = 'Spot Fisso',
    moving_spot = 'Spot Mobile',
    select_spot_type = 'Seleziona Tipo di Spot',

    --cardealer
    no_job = 'Non hai il lavoro giusto per vendere i veicoli.',
    cardealer_catalog = 'Categorie Veicoli',
    no_player = 'Nessun giocatore nelle vicinanze.',
    selected_player = 'Seleziona il giocatore per vendere il veicolo',
    no_vehicle = 'Nessun veicolo trovato in questa categoria.',
    selected_vehicle = 'Seleziona un veicolo',
    menu_cardealer = 'Premi [E] per aprire il catalogo',
    no_permission = 'Non hai i permessi per accedere a questo menu',
    vending_vehicle = 'Hai venduto il veicolo ',
    receveid_vehicle = 'Hai ricevuto il veicolo ',
    targato = ' targato ',
    model_vehicle = 'Modello veicolo non valido!',

    --showroom
    menu_showroom = 'Premi [E] per aprire il catalogo',
    show_category = 'Categorie Veicoli',
    description = 'Visualizza veicoli ',
    vehicle_model = 'Veicoli',
    description_1 = 'Torna al punto di partenza',
    esc = 'Esci',
    notify = 'Contatta il concessionario per acquistare il veicolo. Premi E per uscire dal menù',
    description_2 = 'Acquista questo veicolo',
    title = 'Guarda veicolo e info',
    description_3 = 'Prezzo del veicolo',
    money = 'Prezzo: $',

    ---Bossmenù
    menu_boss = 'Premi [E] per aprire il menù boss',
    saldo_boss = 'Saldo Società: $',
    add_dipendent = 'Assumi Dipendente',
    manage_employees = 'Gestisci Dipendenti',
    deposit = 'Deposita denaro',
    withdraw = 'Preleva denaro',
    title_boss = 'Menù Boss',
    id_player = 'ID del giocatore',
    amount = 'Importo',
    promote = 'Promuovi',
    demote = 'Degrada',
    fire = 'Licenzia',
    action_dipe = 'Azioni Dipendente',
    select_grade = 'Seleziona il grado',
    no_player_boss = 'Nessun giocatore trovato.',
    hired = 'Hai assunto ',
    hired_player = 'Sei stato assunto da ',
    fired = 'Hai licenziato ',
    fired_player = 'Sei stato licenziato da ',
    promoted = 'Hai promosso ',
    promoted_player = 'Sei stato promosso da ',
    demoted = 'Hai degradato ',
    demoted_player = 'Sei stato degradato da ',
    no_money = 'Non hai abbastanza soldi',
    deposit_money = 'Hai depositato $',
    withdraw_money = 'Hai prelevato $',
    no_money_society = 'Non ci sono abbastanza soldi nella società',
    test_drive = 'Test Drive',
    test_drive_desc = 'Prova il veicolo per un breve periodo',
}