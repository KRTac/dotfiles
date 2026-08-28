function file_exists(name)
  local f=io.open(name, "r")
  if f~=nil then io.close(f) return true else return false end
end

function config_exists(config)
  return file_exists(os.getenv("HOME") .. "/.config/hypr/" .. config:gsub("%.", "/") .. ".lua")
end

function require_if_there(config)
  if config_exists(config) then
    require(config)
  end
end

function executable_exists(name)
  local handle = io.popen("command -v " .. name .. " 2>/dev/null")
  local result = handle:read("*l")
  handle:close()
  return result ~= nil
end
