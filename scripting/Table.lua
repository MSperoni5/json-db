function Table()
    local self = {}

    self.databaseName = nil
    self.name = nil
    self.primaryKey = nil
    self.columns = nil
    self.data = nil
    
    -- Restituisce il nome del database
    -- @return string
    self.getDatabaseName = function()
        return self.databaseName
    end

    -- Restituisce il nome della table
    -- @return string
    self.getName = function()
        return self.name
    end

    -- Restituisce se la table ha una primary key
    -- @return boolean
    self.hasPrimaryKey = function()
        return self.primaryKey ~= false
    end

    -- Restituisce la primary key della table
    -- @return string
    self.getPrimaryKey = function()
        return self.primaryKey
    end

    -- Restituisce le colonne della table
    -- @return table
    self.getColumns = function()
        return self.columns
    end

    -- Restituisce i dati della table
    -- @return table
    self.getData = function()
        return self.data
    end

    -- Inizializza la table
    -- @param databaseName string
    -- @param name string
    -- @param content table
    -- @return Table
    self.__init__ = function(databaseName, name, content)
        -- Controlla che il nome del database sia valido
        if not doesValueExistsAndIsOfType(databaseName, "string") then
            error("Database name is required")
            return nil
        end

        -- Controlla che il nome della table sia valido
        if not doesValueExistsAndIsOfType(name, "string") then
            error("Table name is required")
            return nil
        end

        -- Controlla che il contenuto sia valido
        if not doesValueExistsAndIsOfType(content, "table") then
            error("Table content is required")
            return nil
        end

        -- Controlla che il contenuto non sia vuoto
        if not content or not content[1] then
            error("Content is empty")
            return nil
        end

        -- Controlla che la primary key sia valida
        if not doesValueExistsAndIsOfType(content[1].primaryKey, "string") and content[1].primaryKey ~= false then
            error("Primary key is required")
            return nil
        end

        -- Controlla che le colonne siano valide
        if not doesValueExistsAndIsOfType(content[1].columns, "table") or getTableLength(content[1].columns) < 1 then
            error("Columns are required")
            return nil
        end

        -- Controlla che le colonne siano formattate correttamente
        if not doesColumnsAreValid(content[1].columns) then
            return nil
        end

        -- Controlla che la primary key sia una colonna
        if content[1].primaryKey ~= false and not content[1].columns[content[1].primaryKey] then
            error("Primary key is not a column")
            return nil
        end

        -- Controlla che i dati siano validi
        if not doesValueExistsAndIsOfType(content[1].data, "table") then
            error("Data is required")
            return nil
        end

        -- Imposta le variabili di classe
        self.databaseName = databaseName
        self.name = name
        self.primaryKey = content[1].primaryKey
        self.columns = content[1].columns
        self.data = content[1].data
        
        -- Tiene traccia della table caricata
        trace("Table `" .. name .. "` in Database `" .. databaseName .. "` loaded")

        return self
    end

    return self
end