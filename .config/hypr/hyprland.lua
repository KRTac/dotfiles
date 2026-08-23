function file_exists(name)
  local f=io.open(name, "r")
  if f~=nil then io.close(f) return true else return false end
end


require("dms.init")

local hyprmodImport = "hyprland-gui"
if file_exists(os.getenv("HOME") .. "/.config/hypr/" .. hyprmodImport .. ".lua") then
  require(hyprmodImport)
end
