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

    return math.max(scaleStart, math.min(scaleEnd, 1 + (value - startAt) / (endAt - startAt)))
end

local function setupMonitors(withNotif)
    local monitors = hl.get_monitors()

    local auxW = 0
    local auxH = 0
    local laptopW = 0
    local laptopH = 0

    for _, monitor in ipairs(monitors) do
        if monitor.name == "HDMI-A-5" then
            auxW = monitor.width
            auxH = monitor.height
        elseif monitor.name == "eDP-1" then
            laptopW = monitor.width
            laptopH = monitor.height
        end
    end

    if auxW > 0 then
        hl.monitor({
            output = "eDP-1",
            mode = "preferred",
            position = auxW .. "x" .. (auxH - laptopH),
            scale = 1,
            vrr = 0
        })

        hl.monitor({
            output = "HDMI-A-5",
            mode = "preferred",
            position = "0x0",
            scale = scale(auxW),
            vrr = 0
        })

        -- hl.dsp.moveworkspacetomonitor({
        --     workspace = 1,
        --     monitor = "HDMI-A-5",
        -- })

        hl.dsp.focus({
            monitor = "HDMI-A-5",
        })

        if withNotif then
            hl.notification.create({ text = "External monitor detected", timeout = 10000 })
        end
    else
        hl.monitor({
            output = "eDP-1",
            mode = "preferred",
            position = "0x0",
            scale = 1,
            vrr = 0
        })

        -- hl.dsp.moveworkspacetomonitor({
        --     workspace = 1,
        --     monitor = "eDP-1",
        -- })

        hl.dsp.focus({
            monitor = "eDP-1",
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
