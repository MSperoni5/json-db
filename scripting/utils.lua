local resourcePath = GetResourcePath(GetCurrentResourceName())

function getResourcePath()
    return resourcePath
end

function dumpTable(table, nb)
    if nb == nil then 
        nb = 0 
    end
    if type(table) ~= "table" then 
        return tostring(table) 
    end
    local isEmpty = true
    for _ in pairs(table) do
        isEmpty = false
        break
    end
    if isEmpty then
        return "{}"
    end
    local s = "{\n"
    for k, v in pairs(table) do
        if type(k) ~= "number" then 
            k = "\"" .. k .. "\"" 
        end
        s = s .. string.rep("    ", nb + 1) .. "[" .. k .. "] = "
        if type(v) == "table" then
            s = s .. dumpTable(v, nb + 1) .. ",\n"
        else
            s = s .. tostring(v) .. ",\n"
        end
    end
    s = s .. string.rep("    ", nb) .. "}"
    return s
end


function trace(msg)
    if not Config.TraceEnabled then
        return
    end
    print("^3> TRACE ^0(^4" .. msg .. "^0)")
end

function success(msg)
    print("^2SCRIPT SUCCESS: " .. msg)
end

function error(msg)
    print("^1SCRIPT ERROR: " .. msg)
end

function doesValueExistsAndIsOfType(obj, expectedType)
    return obj and type(obj) == expectedType
end

function createDirectory(path, name)
    os.execute("mkdir \"" .. path .. "/" .. name .. "\"")
end

function deleteDirectory(path)
    os.execute("rmdir /s /q \"" .. path .. "\"")
end

function getDirectoriesInPath(path)
    local directories = {}
    local p = io.popen('dir "' .. path .. '" /b /ad 2>nul')
    for directory in p:lines() do
        table.insert(directories, directory)
    end
    p:close()
    return directories
end

function getJsonFilesInPath(path)
    local files = {}
    local p = io.popen('dir "' .. path .. '" /b /a-d 2>nul')
    for file in p:lines() do
        if file:match("%.json$") then
            local fullPath = path .. "\\" .. file
            local f = io.open(fullPath, "r")
            if f then
                local content = f:read("*all")
                f:close()
                files[file:gsub("%.json$", "")] = json.decode(content) or {}
            end
        end
    end
    p:close()
    return files
end

function getTableLength(table)
    local count = 0
    for _ in pairs(table) do 
        count = count + 1 
    end
    return count
end

function doesColumnsAreValid(columns)
    for columnName, columnType in pairs(columns) do
        if not doesValueExistsAndIsOfType(columnName, "string") then
            error("Column name is required as string")
            return false
        end
        if not doesValueExistsAndIsOfType(columnType, "string") then
            error("Column type is required as string")
            return false
        end
        if columnType ~= "number" and columnType ~= "boolean" and columnType ~= "string" and columnType ~= "table" then
            error("Column type is not valid")
            return false
        end
    end
    return true
end

function tableIndexesToString(tbl)
    local result = {}
    for key, _ in pairs(tbl) do
        table.insert(result, "`" .. key .. "`")
    end
    return table.concat(result, ", ")
end

function fileExists(path)
    local f = io.open(path, "r")
    if f then
        f:close()
        return true
    end
    return false
end

function createFile(path, content)
    if not fileExists(path) then
        local f = io.open(path, "w")
        if f then
            f:write(content)
            f:close()
        end
    end
end

function deleteFile(path)
    if fileExists(path) then
        os.remove(path)
    end
end