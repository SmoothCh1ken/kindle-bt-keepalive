local InfoMessage = require("ui/widget/infomessage")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local _ = require("gettext")

local BTKeepalive = WidgetContainer:extend{
    name = "btkeepalive",
    is_doc_only = false,
}

function BTKeepalive:init()
    self.ui.menu:registerToMainMenu(self)
end

function BTKeepalive:addToMainMenu(menu_items)
    menu_items.btkeepalive = {
        text = _("Bluetooth Keepalive"),
        sorting_hint = "tools",
        sub_item_table = {
            {
                text = _("Get MAC Address"),
                callback = function() self:getMACAddress() end,
            },
            {
                text = _("Current Mode"),
                callback = function() self:getCurrentMode() end,
            },
            {
                text = _("Reading Mode"),
                callback = function() self:setReadingMode() end,
            },
            {
                text = _("Always On"),
                callback = function() self:setAlwaysOn() end,
            },
            {
                text = _("Default (Disable)"),
                callback = function() self:setDefault() end,
            },
        },
    }
end

-- NOTA TECNICA: en Kindles 8th-10th gen (chip NXP + radio Broadcom BCM4343)
-- el stack Bluetooth es Broadcom BSA (bsa_server sobre UART). No existe un
-- archivo de config legible ni en /var/local/zbluetooth ni en /opt/zbluetooth
-- (esas rutas son exclusivas de 11th gen+ con pila Bluedroid/btmanagerd).
-- Se consulta en su lugar la propiedad LIPC "ListPaired" de com.lab126.btfd,
-- que es la capa de abstraccion comun a ambos stacks Bluetooth.
function BTKeepalive:getMACAddress()
    local handle = io.popen("lipc-get-prop com.lab126.btfd ListPaired 2>/dev/null")
    local raw = handle and handle:read("*a") or ""
    if handle then handle:close() end

    if raw == "" then
        UIManager:show(InfoMessage:new{
            text = _("No paired devices found.\nPair via Settings → Bluetooth first."),
        })
        return
    end

    local macs = {}
    local seen = {}
    for mac in raw:gmatch("(%x%x:%x%x:%x%x:%x%x:%x%x:%x%x)") do
        mac = mac:upper()
        if not seen[mac] then
            seen[mac] = true
            table.insert(macs, mac)
        end
    end

    if #macs == 0 then
        UIManager:show(InfoMessage:new{
            text = _("No paired devices found."),
        })
        return
    end

    local start = math.max(1, #macs - 2)
    local lines = {}
    for i = start, #macs do
        table.insert(lines, macs[i])
    end

    UIManager:show(InfoMessage:new{
        text = _("Paired Bluetooth Devices:\n\n") .. table.concat(lines, "\n"),
    })
end

function BTKeepalive:getCurrentMode()
    local f = io.open("/mnt/us/btkeepalive/config.conf", "r")
    if not f then
        UIManager:show(InfoMessage:new{
            text = _("Config file missing.\nPlease run setup first."),
        })
        return
    end

    local mode = f:read("*l")
    f:close()

    local mode_map = {
        reading = _("Reading Mode"),
        ["always-on"] = _("Always On Mode"),
        default = _("Default (Disabled)"),
    }
    local display = mode_map[mode]

    UIManager:show(InfoMessage:new{
        text = _("Current Mode: ") .. (display or _("Unknown")),
        timeout = 3,
    })
end

function BTKeepalive:setReadingMode()
    self:runShell("/mnt/us/extensions/btkeepalive/set_reading.sh", _("Reading Mode enabled"))
end

function BTKeepalive:setAlwaysOn()
    self:runShell("/mnt/us/extensions/btkeepalive/set_always_on.sh", _("Always On Mode enabled"))
end

function BTKeepalive:setDefault()
    self:runShell("/mnt/us/extensions/btkeepalive/set_default.sh", _("Disabled (default mode)"))
end

function BTKeepalive:runShell(script, msg)
    if not io.open(script, "r") then
        UIManager:show(InfoMessage:new{
            text = _("Script not found:\n") .. script,
        })
        return
    end
    os.execute("/bin/sh " .. script .. " 2>/dev/null")
    UIManager:show(InfoMessage:new{
        text = msg,
        timeout = 3,
    })
end

return BTKeepalive
