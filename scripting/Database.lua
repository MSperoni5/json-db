function Database()
    local self = {}

    self.name = nil
    self.tables = nil

    -- Controlla se una table esiste
    -- @param name string
    -- @return boolean
    self.doesTableExists = function(name)
        return self.tables[name] ~= nil
    end

    -- Restituisce una table
    -- @param name string
    -- @return Table
    self.getTable = function(name)
        return self.tables[name]
    end
    
    -- Crea una table
    -- @param name string
    -- @param columns table
    -- @param primaryKey string or false
    -- @return Table
    self.createTable = function(name, columns, primaryKey)
        -- Controlla che il nome sia valido
        if not doesValueExistsAndIsOfType(name, "string") then
            error("Table name is required")
            return nil
        end

        -- Aggiusta il valore di primaryKey
        if primaryKey == nil then
            primaryKey = false
        end

        -- Controlla che la table non esista già
        if self.doesTableExists(name) then
            return self.getTable(name)
        end

        -- Crea la table
        local newTable = Table()
        local content = {{
            ["primaryKey"] = primaryKey,
            ["columns"] = columns,
            ["data"] = {},
        }}
        self.tables[name] = newTable.__init__(self.name, name, content)

        -- Controlla che la table sia stata creata
        if not self.doesTableExists(name) then
            error("Table `" .. name .. "` creation failed")
            return nil
        end
        
        -- Crea il file json e ci scrive il contenuto default
        createFile(getResourcePath() .. "/session/" .. self.name .. "/" .. name .. ".json", json.encode(content))

        -- Tiene traccia della table creata
        trace("Table `" .. name .. "` created in Database `" .. self.name .. "`")

        return self.tables[name]
    end

    -- Elimina una table
    -- @param name string
    -- @return boolean
    self.deleteTable = function(name)
        -- Controlla che il nome sia valido
        if not doesValueExistsAndIsOfType(name, "string") then
            error("Table name is required")
            return false
        end

        -- Controlla che la table esista
        if not self.doesTableExists(name) then
            error("Table `" .. name .. "` does not exists")
            return false
        end

        -- Elimina la table
        self.tables[name] = nil
        deleteFile(getResourcePath() .. "/session/" .. self.name .. "/" .. name .. ".json")

        -- Tiene traccia della table eliminata
        trace("Table `" .. name .. "` deleted from Database `" .. self.name .. "`")

        return true
    end

    -- Inizializza il database
    -- @param name string
    -- @return Database
    self.__init__ = function(name)
        -- Controlla che il nome sia valido
        if not doesValueExistsAndIsOfType(name, "string") then
            error("Database name is required")
            return nil
        end

        -- Imposta le variabili di classe come default
        self.name = name
        self.tables = {}

        -- Carica tutte le table che trova nella cartella del database
        local jsonFiles = getJsonFilesInPath(getResourcePath() .. "/session/" .. name)
        for fileName, fileContent in pairs(jsonFiles) do
            -- Controlla che la table non sia già stata caricata
            if not self.doesTableExists(fileName) then
                -- Carica la table
                local newTable = Table()
                self.tables[fileName] = newTable.__init__(name, fileName, fileContent)

                -- Controlla che la table sia stata caricata
                if not self.doesTableExists(fileName) then
                    error("Table `" .. fileName .. "` in Database `" .. self.name .. "` loading failed")
                end
            -- Altrimenti, se la table esiste già, lancia un errore
            else
                error("Table `" .. fileName .. "` already exists")
            end
        end

        -- Tiene traccia del database caricato
        trace("Database `" .. name .. "` with Tables [" .. tableIndexesToString(self.tables) .. "] loaded")

        return self
    end

    return self
end