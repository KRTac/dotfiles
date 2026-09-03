hl.on("hyprland.start", function()
  hl.exec_cmd("dms run --session")
end)

require("common.animations")
require("common.autostart")
require("common.binds")
require("common.general")
require("common.monitor-hotplug")
require("common.window-rules")
require_if_there("dms.colors")

if os.getenv("HYPR_MONITOR_HOTPLUG") ~= "1" then
  require_if_there("dms.outputs")
end
