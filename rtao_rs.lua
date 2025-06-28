-- 📦 CONFIG
_G.WebhookURL = "https://discord.com/api/webhooks/1264293481216610461/gnjmV3KrnLLmnVfz0qwh0JMUdOP44bhki2aaja_XjkA-UsyalWUxLgHjySZdNZbbVcUK" -- ใส่ webhook ของคุณ
_G.Enabled = true
_G.Layout = {
    ["ROOT/SeedStock/Stocks"] = { title = "🌱 SEEDS STOCK", color = 65280 },
    ["ROOT/GearStock/Stocks"] = { title = "🛠️ GEAR STOCK", color = 16753920 },
    ["ROOT/PetEggStock/Stocks"] = { title = "🥚 EGG STOCK", color = 16776960 },
    ["ROOT/CosmeticStock/ItemStocks"] = { title = "🎨 COSMETIC STOCK", color = 16737792 },
    ["ROOT/EventShopStock/Stocks"] = { title = "🎁 EVENT STOCK", color = 10027263 }
}

-- 📡 SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local DataStream = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("DataStream")

-- 🌐 HTTP fallback
local requestFunc = http_request or request or syn and syn.request
if not requestFunc then
    warn("[❌] HTTP request ไม่รองรับบน executor นี้")
end

-- 🔄 แปลง stock เป็น string
local function GetStockString(stock)
    local s = ""
    for name, data in pairs(stock) do
        local display = data.EggName or name
        s ..= (`{display} x{data.Stock}\n`)
    end
    return s
end

-- 📤 ส่ง webhook แยก embed ต่อหมวด
local function SendSingleEmbed(title, bodyText, color)
    if not _G.Enabled or not requestFunc then return end
    if bodyText == "" then return end

    local body = {
        embeds = {{
            title = title,
            description = bodyText,
            color = color,
            timestamp = DateTime.now():ToIsoDate(),
            footer = {
                text = "Grow a Garden Stock Bot (Mobile)"
            }
        }}
    }

    requestFunc({
        Url = _G.WebhookURL,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode(body)
    })
end

-- 🧩 ค้นหา packet ที่ต้องการจาก data
local function GetPacket(data, key)
    for _, packet in ipairs(data) do
        if packet[1] == key then
            return packet[2]
        end
    end
end

-- 📥 รับ event และส่งรายงาน
DataStream.OnClientEvent:Connect(function(eventType, profile, data)
    if eventType ~= "UpdateData" then return end
    if not profile:find(LocalPlayer.Name) then return end

    for path, layout in pairs(_G.Layout) do
        local stockData = GetPacket(data, path)
        if stockData then
            local stockStr = GetStockString(stockData)
            if stockStr ~= "" then
                SendSingleEmbed(layout.title, stockStr, layout.color)
            end
        end
    end
end)

print("[✅] Stock Checker พร้อมทำงาน (แบบแยก Embed)")
