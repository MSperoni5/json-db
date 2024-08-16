function Session()
    local self = {}

    self.active = nil
    self.databases = nil

    -- Restituisce se la sessione è attiva o meno
    -- @return boolean
    self.isActive = function()
        return self.active
    end

    -- Dato il nome di un database, restituisce il database
    -- @param name string
    -- @return boolean
    self.doesDatabaseExists = function(name)
        return self.databases[name] ~= nil
    end

    -- Restituisce un database dato il nome
    -- @param name string
    -- @return Database
    self.getDatabase = function(name)
        return self.databases[name]
    end

    -- Crea un database dato il nome
    -- @param name string
    -- @return Database
    self.createDatabase = function(name)
        -- Controlla che il nome sia valido
        if not doesValueExistsAndIsOfType(name, "string") then
            error("Database name is required")
            return nil
        end
        
        -- Controlla che il database non esista già
        if self.doesDatabaseExists(name) then
            return self.getDatabase(name)
        end

        -- Crea il database
        local newDatabase = Database()
        self.databases[name] = newDatabase.__init__(name)

        -- Controllo che il database sia stato creato
        if not self.doesDatabaseExists(name) then
            error("Database `" .. name .. "` creation failed")
            return nil
        end

        -- Crea la cartella del database
        createDirectory(getResourcePath(), "session/" .. name)

        -- Tiene traccia del database creato
        trace("Database `" .. name .. "` created")

        return self.databases[name]
    end

    -- Dato il nome di un database, lo elimina
    -- @param name string
    -- @return boolean
    self.deleteDatabase = function(name)
        -- Controlla che il nome sia valido
        if not doesValueExistsAndIsOfType(name, "string") then
            error("Database name is required")
            return false
        end

        -- Controlla che il database esista
        if not self.doesDatabaseExists(name) then
            error("Database `" .. name .. "` does not exists")
            return false
        end

        -- Elimina il database 
        self.databases[name] = nil
        deleteDirectory(getResourcePath() .. "/session/" .. name)

        -- Tiene traccia del database eliminato
        trace("Database `" .. name .. "` deleted")

        return true
    end

    -- Inizializza la sessione
    self.__init__ = function()
        -- Imposta le variabili di classe come default
        self.active = false
        self.databases = {}

        local resourcePath = getResourcePath()

        -- Crea la cartella della sessione nel caso non dovesse esserci
        createDirectory(resourcePath, "session")

        -- Inizializza tutti i database che trova nella sessione
        local databases = getDirectoriesInPath(resourcePath .. "/session")
        for i = 1, #databases do
            -- Controlla che il database non sia già stato caricato
            if not self.doesDatabaseExists(databases[i]) then
                -- Carica il database
                local newDatabase = Database()
                self.databases[databases[i]] = newDatabase.__init__(databases[i])

                -- Controlla che il database sia stato caricato
                if not self.doesDatabaseExists(databases[i]) then
                    error("Database `" .. databases[i] .. "` loading failed")
                end
            -- Altrimenti notifica che il database esiste già
            else
                error("Database `" .. databases[i] .. "` already exists")
            end
        end

        -- Imposta la sessione come attiva
        self.active = true
        
        -- Notifica il successo
        success("Session initialized")
    end

    return self
end