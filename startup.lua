-- Check if all files exist
local version = "1"

if not fs.exists("NSPhone") then fs.makeDir("NSPhone") end
if http.get("https://raw.githubusercontent.com/banana-boye/NSPhone/refs/heads/main/version.txt").readAll() ~= version then
    for _, file in pairs(fs.list("SI")) do
        if file then
            shell.run("delete SI/"..file)
        end
    end
    shell.run("delete startup.lua")
    shell.run("wget https://raw.githubusercontent.com/banana-boye/NSPhone/refs/heads/main/startup.lua startup.lua")
    shell.run("reboot")
end
if not fs.exists("NSPhone/basalt.lua") then shell.run("wget run https://basalt.madefor.cc/install.lua release latest.lua NSPhone/basalt.lua") end
if not fs.exists("NSPhone/stringtools.lua") then shell.run("wget https://raw.githubusercontent.com/banana-boye/CC_stringtools/refs/heads/main/stringtools.lua NSPhone/stringtools.lua") end
if not fs.exists("NSPhone/DiscoHook.lua") then shell.run("wget wget https://raw.githubusercontent.com/banana-boye/DiscoHook/refs/heads/main/DiscoHook.lua DiscoHook NSPhone/DiscoHook.lua") end
if not fs.exists("NSPhone/main.lua") then shell.run("wget https://raw.githubusercontent.com/banana-boye/NSPhone/refs/heads/main/NSPhone/main.lua NSPhone/stringtools.lua") end

-- Run
shell.run("NSPhone/main.lua")