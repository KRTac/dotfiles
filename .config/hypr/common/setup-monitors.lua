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

local function setupMonitors(withNotif)
    local monitors = hl.get_monitors()

    local auxW = 0
    local auxH = 0
    local laptopW = 0
    local laptopH = 0

    for _, monitor in ipairs(monitors) do
        if monitor.name == externalMonitor then
            auxW = monitor.width
            auxH = monitor.height
        elseif monitor.name == laptopMonitor then
            laptopW = monitor.width
            laptopH = monitor.height
        end
 
        if auxW > 0 and laptopW > 0 then
            break
        end
    end

    if auxW > 0 then
        hl.monitor({
            output = laptopMonitor,
            mode = "preferred",
            position = auxW .. "x" .. (auxH - laptopH),
            scale = 1,
            vrr = 0
        })

        hl.monitor({
            output = externalMonitor,
            mode = "preferred",
            position = "0x0",
            scale = scale(auxW),
            vrr = 0
        })

        -- hl.dsp.moveworkspacetomonitor({
        --     workspace = 1,
        --     monitor = externalMonitor,
        -- })

        hl.dsp.focus({
            monitor = externalMonitor,
        })

        if withNotif then
            hl.notification.create({ text = "External monitor detected", timeout = 10000 })
        end
    else
        hl.monitor({
            output = laptopMonitor,
            mode = "preferred",
            position = "0x0",
            scale = 1,
            vrr = 0
        })

        -- hl.dsp.moveworkspacetomonitor({
        --     workspace = 1,
        --     monitor = laptopMonitor,
        -- })

        hl.dsp.focus({
            monitor = laptopMonitor,
        })

        if withNotif then
            hl.notification.create({ text = "External monitor disconnected", timeout = 10000 })
        end
    end
end

local notifyAfter = os.time() + 5
local handleEvent = function()
    setupMonitors(notifyAfter < os.time())
end

hl.on("monitor.added", handleEvent)
hl.on("monitor.removed", handleEvent)

setupMonitors(false)
