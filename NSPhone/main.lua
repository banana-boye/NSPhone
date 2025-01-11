local basalt = require("basalt")
local DiscoHook = require("DiscoHook")
local webhook = DiscoHook.create("https://discord.com/api/webhooks/1316102809002836059/B_2l6RncV-J8dUwXGSHl7r2v0f0o1K5sXi8ckZO45cK8pczq6_vaL7ELbn8gn3RJLEvE")
local version = 1.003
if tonumber(http.get("https://pastebin.com/raw/L8PN2RTy").readAll()) ~= version then
    fs.delete(shell.getRunningProgram())
    shell.run("pastebin get d6vviWbb startup.lua")
    print("rebooting, update successful")
    shell.run("reboot")
end
require("stringtools")()
local main = basalt.createFrame()
    :setSize(26, 20)
    :setTheme(
        {
            BaseFrameBG = colors.gray,
            BaseFrameText = colors.gray,
            FrameBG = colors.black,
            FrameText = colors.gray,
            ButtonBG = colors.lightBlue,
            ButtonText = colors.gray,
            CheckboxBG = colors.gray,
            CheckboxText = colors.white,
            InputBG = colors.gray,
            InputText = colors.lightGray,
            TextfieldBG = colors.lightGray,
            TextfieldText = colors.gray,
            ListBG = colors.gray,
            ListText = colors.gray,
            MenubarBG = colors.gray,
            MenubarText = colors.gray,
            DropdownBG = colors.gray,
            DropdownText = colors.gray,
            RadioBG = colors.gray,
            RadioText = colors.gray,
            SelectionBG = colors.gray,
            SelectionText = colors.lightGray,
            GraphicBG = colors.blue,
            ImageBG = colors.gray,
            PaneBG = colors.gray,
            ProgramBG = colors.gray,
            ProgressbarBG = colors.gray,
            ProgressbarText = colors.gray,
            ProgressbarActiveBG = colors.gray,
            ScrollbarBG = colors.lightGray,
            ScrollbarText = colors.blue,
            ScrollbarSymbolColor = colors.blue,
            SliderBG = false,
            SliderText = colors.gray,
            SliderSymbolColor = colors.gray,
            SwitchBG = colors.lightGray,
            SwitchText = colors.gray,
            LabelBG = false,
            LabelText = colors.gray,
            GraphBG = colors.gray,
            GraphText = colors.gray
        }
    )
local subFrames = {
    mainMenu = main:addFrame()
        :setSize("parent.w", "parent.h - 1")
        :setPosition(1,2)
        :setBackground(colors.lightGray)
        :hide(),
    checklist = main:addFrame()
        :setSize("parent.w", "parent.h - 1")
        :setPosition(1,2)
        :setBackground(colors.lightGray)
        :hide()
}
local allChars = {}
local id = os.getComputerID()
 
for i = 0, 255 do
    allChars[i] = string.char(i)
end
local function encrypt(message)
    message = string.fracture(textutils.serialise(message))
    local new = ""
    for _, char in pairs(message) do
        for _idx, _char in ipairs(allChars) do
            if char == _char then
                new = new..allChars[(_idx+id)%#allChars]
            end
        end
    end
    return new.."_"..id
end
 
local function decrypt(message)
    message = string.fracture(message)
    local unlockId = ""
    for i = #message, 1, -1 do
        if message[i] ~= "_" then
            unlockId = unlockId..message[i]
        else
            for j = i, #message do
                message[j] = nil
            end
            break
        end
    end
---@diagnostic disable-next-line: cast-local-type
    unlockId = tonumber(string.reverse(unlockId))
    local new = ""
    for _, char in pairs(message) do
        for _idx, _char in ipairs(allChars) do
            if char == _char then
                new = new..allChars[(_idx-unlockId)%#allChars]
            end
        end
    end
    return textutils.unserialise(new)
end


--storage
local temp
if not fs.exists("./storage.json") then
    temp = fs.open("./storage.json", "w")
    temp.write(textutils.serialiseJSON({
        personalChecklist = {},
        lastScreen = "mainMenu"
    }))
    temp.close()
end
local storageJson = fs.open("./storage.json", "r")
local storage = textutils.unserialiseJSON(storageJson.readAll())
subFrames[storage.lastScreen]:show()
local function saveStorage()
    temp = fs.open("storage.json", "w")
    temp.write(textutils.serialiseJSON(storage))
    temp.close()
end

local function openSubFrame(index)
    for _, frame in pairs(subFrames) do
        frame:hide()
    end
    subFrames[index]:show()
    storage.lastScreen = index
    saveStorage()
end


--main menu placeholder
subFrames.mainMenu:addLabel()
    :setText("No main menu, have a guide: below is your app bar with a checklist and a return to main menu button, top right is the time, the triangle is the connection status to base, red is disconnected, yellow means no modem is connected and green is connected")
    :setSize(20,15)

--checklist
local space_used = 0
local taskObjects = {}
local tasks = subFrames.checklist:addFrame()
    :setSize(25,15)
    :setBackground(colors.lightGray)

subFrames.checklist:addScrollbar()
    :setPosition(26,1)
    :setSize(1,15)
    :setScrollAmount(#storage.personalChecklist*3)
    :onChange(function(_, _, value)
        tasks:setOffset(0, value-1)
    end)
local input = subFrames.checklist:addFrame()
    :setSize("parent.w", "parent.h")
    :setBackground(colors.lightGray)
    :hide()

input:addLabel()
    :setText("Create task:")
local inText = input:addInput()
    :setPosition(2,2)
    :setSize(24,1)
    :setBackground(colors.gray)
    :setForeground(colors.black)
    :setDefaultText("Clean the dishes")

input:addButton()
    :setPosition(1,4)
    :setText("Cancel")
    :setSize(6,1)
    :setBackground(colors.red)
    :setForeground(colors.black)
    :onClick(function()
        input:hide()
        tasks:show()
    end)

tasks:setSize(16, space_used+15)
local function updatePersonalTasks()
    tasks:removeChildren()
    for index, task in pairs(storage.personalChecklist) do
        local indent = index * 2 + string.height(table.concat(string.wordWrap(storage.personalChecklist[index-1] and storage.personalChecklist[index-1] or "",16),"\n"))
        local checkBox = tasks:addCheckbox()
            :setSize(1,1)
            :setPosition(2, indent)
            :onChange(function ()
                table.remove(storage.personalChecklist, index)
                updatePersonalTasks()
                saveStorage()
            end)

    
        local taskLabel = tasks:addLabel()
        taskLabel:setText(task)
        taskLabel:setPosition(4, indent)
        taskLabel:setSize(16, "parent.h")
        space_used = space_used + indent + string.height(task)
    
        table.insert(taskObjects,{checkBox,taskLabel})
    end
    tasks:addButton()
        :setSize(1,1)
        :setPosition(2, (#storage.personalChecklist+1) * 2 + string.height(table.concat(string.wordWrap(storage.personalChecklist[#storage.personalChecklist-1] and storage.personalChecklist[#storage.personalChecklist-1] or "",25),"\n")))
        :setBackground(colors.green)
        :setForeground(colors.black)
        :setText("+")
        :onClick(function()
            tasks:hide()
            input:show()
        end)
end
input:addButton()
    :setPosition(20,4)
    :setText("Finish")
    :setSize(6,1)
    :setBackground(colors.green)
    :setForeground(colors.black)
    :onClick(function()
        table.insert(storage.personalChecklist, inText:getValue())
        saveStorage()
        input:hide()
        updatePersonalTasks()
        tasks:show()
    end)
updatePersonalTasks()


-- stuff that stays on top
--topBar
local topBar = main:addFrame():setSize("parent.w",1):setBackground(colors.blue)
local factionLabel = topBar:addLabel()
    :setText("NSPhone")
    :setForeground(colors.black)
local timeLabel = topBar:addLabel()
    :setForeground(colors.black)
local connectionSymbol = topBar:addButton()
    :setText("\31")
    :setForeground(colors.black)
    :setBackground(colors.blue)
    :setSize(1,1)

local function awaitMessage(channel, timeOut, condition)
    local toReturn = {}
    parallel.waitForAny(function()
        repeat
            os.sleep(1)
            timeOut = timeOut - 1
        until timeOut <= 0
        toReturn = {false}
    end, function()
        while next(toReturn) == nil do
            local received = table.pack(os.pullEvent("modem_message"))
            if received[3] == channel then
                received[5] = decrypt(received[5])
                if condition(received[5]) then
                    toReturn = {true, received}
                else
                    toReturn = {false}
                end
            end
        end
    end)
    return table.unpack(toReturn)
end
local modem, _ = peripheral.find("modem")
modem.open(48084)
local function attemptConnection()
    modem, _ = peripheral.find("modem")
    if modem ~= nil then
        --[[
            48084: Receive connection verification
            48184: Send connection verification
        ]]
        modem.transmit(48184, 48084, encrypt({
            operation = "connect",
            connector = "phone",
            lookingFor = "home"
        }))
        local success, _ = awaitMessage(48084, 10, function(message)
            if message.name == "home" and message.operation == "connect" and message.status == true then
                return true
            else
                return false
            end
        end)
        return success
    else
        return nil
    end
end
local connectionThread = main:addThread()
    :start(function()
        while true do
            local connectionStatus = attemptConnection()
            if connectionStatus == nil then
                connectionSymbol:setText("\17")
                    :setForeground(colors.yellow)
            elseif connectionStatus then
                connectionSymbol:setText("\30")
                    :setForeground(colors.green)
            else
                connectionSymbol:setText("\31")
                    :setForeground(colors.red)
            end
            os.sleep(1)
        end
    end)

--local radarThread = main:addThread()
--    :start(function()
--        modem.open(37073)
--        while true do
--            local _, _, channel, replyChannel, message, _ = os.pullEvent("modem_message")
--            message = decrypt(message)
--            if message.lookingForType == "phone" and message.operation == "radarCheck" and message.connector == "pc" then
--                modem.transmit(replyChannel, channel, encrypt({
--                    operation = "radarResponse",
--                    connector = "phone",
--                    lookingFor = message.sender
--                }))
--            end
--        end
--    end)

local clockThread = main:addThread()
    :start(function()
        local time = textutils.formatTime(os.time(),true)
        local position = 26-string.len(time)
        timeLabel:setText(time):setPosition(position)
        while true do
            time = textutils.formatTime(os.time(),true)
            timeLabel:setText(time):setPosition(position)
            connectionSymbol:setPosition(position-2)
            os.sleep(0.5)
        end
    end)

--appBar
local appBar = main:addFrame():setSize("parent.w",5):setPosition(1,16):setBackground(colors.gray)

--checklist button
appBar:addButton()
    :setText("\140\140\140")
    :setVerticalAlign("top")
    :setBackground(false)
    :setSize(5, 3)
    :setPosition(11,2)
    :onClick(function()
        updatePersonalTasks()
        openSubFrame("checklist")
    end)
appBar:addPane()
    :setPosition(11,2)
    :setSize(5,3)
    :setBackground(colors.white)
appBar:addPane()
    :setPosition(12,1)
    :setSize(3,1)
    :setBackground(false, "\95",colors.lightGray)
appBar:addLabel()
    :setText("\140\140\140\n\140\140\140")
    :setPosition(12,3)

--main menu button
appBar:addButton()
    :setText("<")
    :setBackground(colors.white)
    :setSize(5,3)
    :setPosition(2,2)
    :onClick(function()
        openSubFrame("mainMenu")
    end)

basalt.autoUpdate()