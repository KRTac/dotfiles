local function scale(value, startAt, endAt)
  startAt = startAt or 2560
  endAt = endAt or 3840
  local scaleStart = 1
  local scaleEnd = 2

  if value <= startAt then
    return scaleStart
  end

  if value >= endAt then
    return scaleEnd
  end

  local scale = math.max(scaleStart, math.min(scaleEnd, 1 + (value - startAt) / (endAt - startAt)))

  return math.floor(scale * 100 + 0.5) / 100
end

local externalMonitor = "HDMI-A-5"
local laptopMonitor = "eDP-1"
local notificationDurationMs = 10000

local function setup_monitors(withNotif)
  if os.getenv("HYPR_MONITOR_HOTPLUG") ~= "1" then
    return
  end

  local monitors = hl.get_monitors()

  local auxW = 0
  local auxH = 0
  local auxFreq = 0
  local laptopW = 0
  local laptopH = 0

  for _, monitor in ipairs(monitors) do
    if monitor.name == externalMonitor then
      auxW = monitor.width
      auxH = monitor.height
      auxFreq = monitor.refresh_rate
    elseif monitor.name == laptopMonitor then
      laptopW = monitor.width
      laptopH = monitor.height
    end
 
    if auxW > 0 and laptopW > 0 then
      break
    end
  end

  local notificationMain = ""
  local notificationSub = ""

  if auxW > 0 then
    hl.monitor({
      output = laptopMonitor,
      mode = "preferred",
      position = auxW .. "x" .. (auxH - laptopH),
      scale = 1,
      vrr = 0
    })

    local auxScale = scale(auxW)

    hl.monitor({
      output = externalMonitor,
      mode = "preferred",
      position = "0x0",
      scale = auxScale,
      vrr = 0
    })

    hl.dispatch(hl.dsp.workspace.move({ workspace = 1, monitor = externalMonitor }))
    hl.dispatch(hl.dsp.workspace.move({ workspace = 2, monitor = laptopMonitor }))
    hl.dispatch(hl.dsp.focus({ monitor = externalMonitor }))

    if withNotif then
      notificationMain = "Display connected"
      notificationSub = string.format(
        "%dx%d@%.2fHz, %.2f scale",
        auxW,
        auxH,
        auxFreq,
        auxScale
      )
    end
  else
    hl.monitor({
      output = laptopMonitor,
      mode = "preferred",
      position = "0x0",
      scale = 1,
      vrr = 0
    })

    hl.dispatch(hl.dsp.workspace.move({ workspace = 1, monitor = laptopMonitor }))
    hl.dispatch(hl.dsp.focus({ monitor = laptopMonitor }))

    withNotif = false
  end

  if withNotif then
    hl.exec_cmd(string.format(
      "notify-send -t %d -e '%s' '%s'",
      notificationDurationMs,
      notificationMain,
      notificationSub
    ))
  end
end

local notifyAfter = os.time() + 5
local has_notif = executable_exists("notify-send")

local handleEvent = function()
  setup_monitors(has_notif and notifyAfter < os.time())
end

hl.on("monitor.added", handleEvent)
hl.on("monitor.removed", handleEvent)

setup_monitors(false)
