local resource = GetCurrentResourceName()

local Tunnel = module('vrp', 'lib/Tunnel')
local Proxy = module('vrp', 'lib/Proxy')

local vRP = Proxy.getInterface('vRP')
local vRPclient = Tunnel.getInterface('vRP', resource)

local OverExtended = exports['oxmysql']

local database = {
    vehicle = 'vrp_user_vehicles',
    newbie = 'vrp_newbie_bonus'
}

function comma_value(amount)
    local formatted = amount
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k == 0) then
            break
        end
    end
    return formatted
end

function add(type, user_id, value, amount)
    local source = vRP.getUserSource({user_id})
    local name = vRP.getPlayerName({source})

    if type == 'cash' then
        vRP.giveMoney({user_id, value})
        print(string.format('[STORY_CM] [+] cash added: %s (%d번), %s원', name, user_id, tostring(comma_value(value))))

    elseif type == 'bank' then
        vRP.giveBankMoney({user_id, value})
        print(string.format('[STORY_CM] [+] bank money added: %s (%d번), %s원', name, user_id, tostring(comma_value(value))))

    elseif type == 'item' then
        vRP.giveInventoryItem({user_id, value, amount, true})
        print(string.format('[STORY_CM] [+] item added: %s (%d번), %s (%s개)', name, user_id, value, tostring(comma_value(amount))))

    elseif type == 'vehicle' then
        OverExtended:execute(
            'INSERT IGNORE INTO ' .. database.vehicle .. '(user_id,vehicle) VALUES(@user_id,@vehicle)',
            {user_id = user_id, vehicle = value}
        )
        print(string.format('[STORY_CM] [+] vehicle added: %s (%d번), %s', name, user_id, value))

    elseif type == 'group' then
        vRP.addUserGroup({user_id, value})
        print(string.format('[STORY_CM] [+] group added: %s (%d번), %s', name, user_id, value))

    else
        print(string.format('[STORY_CM] [!] 지정되지 않은 명령어입니다: %s', type))
    end
end

function remove(type, user_id, value, amount)
    local source = vRP.getUserSource({user_id})
    local name = vRP.getPlayerName({source})

    if type == 'cash' then
        local currentValue = vRP.getMoney({user_id})
        vRP.setMoney({user_id, currentValue - value})
        print(string.format('[STORY_CM] [-] cash removed: %s (%d번), %s원', name, user_id, tostring(comma_value(value))))

    elseif type == 'bank' then
        local currentValue = vRP.getBankMoney({user_id})
        vRP.setBankMoney({user_id, currentValue - value})
        print(string.format('[STORY_CM] [-] bank money removed: %s (%d번), %s원', name, user_id, tostring(comma_value(value))))

    elseif type == 'item' then
        vRP.tryGetInventoryItem({user_id, value, amount, true})
        print(string.format('[STORY_CM] [-] item removed: %s (%d번), %s (%s개)', name, user_id, value, tostring(comma_value(amount))))

    elseif type == 'vehicle' then
        OverExtended:execute(
            'DELETE FROM ' .. database.vehicle .. ' WHERE user_id = @user_id AND vehicle = @vehicle',
            {user_id = user_id, vehicle = value}
        )
        print(string.format('[STORY_CM] [-] vehicle removed: %s (%d번), %s', name, user_id, value))

    elseif type == 'group' then
        vRP.removeUserGroup({user_id, value})
        print(string.format('[STORY_CM] [-] group removed: %s (%d번), %s', name, user_id, value))

    else
        print('[STORY_CM] [!] 지정되지 않은 명령어입니다.')
    end
end

function reset(type, user_id)
    local source = vRP.getUserSource({user_id})
    local name = vRP.getPlayerName({source})

    if type == 'cash' then
        vRP.setMoney({user_id, 0})
        vRPclient.notify(source, {'시스템 관리자에 의해 모든 현금이 회수되었습니다.'})
        print(string.format('[STORY_CM] [/] cash reset: %s (%d번)', name, user_id))

    elseif type == 'bank' then
        vRP.setBankMoney({user_id, 0})
        vRPclient.notify(source, {'시스템 관리자에 의해 모든 계좌 잔액이 회수되었습니다.'})
        print(string.format('[STORY_CM] [/] bank money reset: %s (%d번)', name, user_id))

    elseif type == 'item' then
        vRP.clearInventory({user_id})
        vRPclient.notify(source, {'시스템 관리자에 의해 모든 아이템이 회수되었습니다.'})
        print(string.format('[STORY_CM] [/] inventory reset: %s (%d번)', name, user_id))

    elseif type == 'vehicle' then
        OverExtended:execute(
            'DELETE FROM ' .. database.vehicle .. ' WHERE user_id = @user_id',
            {user_id = user_id}
        )
        vRPclient.notify(source, {'시스템 관리자에 의해 모든 차량이 회수되었습니다.'})
        print(string.format('[STORY_CM] [/] vehicle reset: %s (%d번)', name, user_id))

    elseif type == 'newbiecode' then
        OverExtended:execute(
            'DELETE FROM ' .. database.newbie .. ' WHERE user_id = @user_id',
            {user_id = user_id}
        )
        print(string.format('[STORY_CM] [/] database - ' .. database.newbie .. ', reset: %s (%d번)', name, user_id))

    elseif type == 'newbiecode-discord' then
        OverExtended:execute(
            'UPDATE ' .. database.newbie .. ' SET state = 1 WHERE user_id = @user_id',
            {user_id = user_id}
        )
        print(string.format('[STORY_CM] [/] database - ' .. database.newbie .. ', state = 1: %s (%d번)', name, user_id))

    elseif type == 'newbiecode-reward' then
        OverExtended:execute(
            'UPDATE ' .. database.newbie .. ' SET state = 2 WHERE user_id = @user_id',
            {user_id = user_id}
        )
        print(string.format('[STORY_CM] [/] database - ' .. database.newbie .. ', state = 2: %s (%d번)', name, user_id))

    else
        print('[STORY_CM] [!] 지정되지 않은 명령어입니다.')
    end
end

local function checkNumberOrString(value)
    return (tonumber(value) ~= nil) and 'number' or 'string'
end

AddEventHandler('rconCommand', function(commandName, args)
    local prefix = 'story'

    if string.sub(commandName:lower(), 1, #prefix) == prefix then
        local command = string.lower(args[1])

        if command == 'add' then
            if #args == 4 or #args == 5 then
                local type = args[2]
                local user_id = vRP.getUserId({tonumber(args[3])})
                local value = args[4]
                local amount = tonumber(args[5]) or nil

                if user_id then
                    local valueType = checkNumberOrString(value)
                    if valueType == 'number' then
                        add(type, user_id, tonumber(value), amount)
                    elseif valueType == 'string' then
                        add(type, user_id, value, amount)
                    end
                    CancelEvent()
                else
                    print('[STORY_CM] [!] 대상자가 접속 중이지 않거나 값이 잘못되었습니다.')
                end
            end

        elseif command == 'remove' then
            if #args == 4 or #args == 5 then
                local type = args[2]
                local user_id = vRP.getUserId({tonumber(args[3])})
                local value = args[4]
                local amount = tonumber(args[5]) or nil

                if user_id then
                    local valueType = checkNumberOrString(value)
                    if valueType == 'number' then
                        remove(type, user_id, tonumber(value), amount)
                    elseif valueType == 'string' then
                        remove(type, user_id, value, amount)
                    end
                    CancelEvent()
                else
                    print('[STORY_CM] [!] 대상자가 접속 중이지 않거나 값이 잘못되었습니다.')
                end
            end

        elseif command == 'reset' then
            if #args == 3 then
                local type = args[2]
                local user_id = vRP.getUserId({tonumber(args[3])})

                if user_id then
                    reset(type, user_id)
                    CancelEvent()
                else
                    print('[STORY_CM] [!] 대상자가 접속 중이지 않거나 값이 잘못되었습니다.')
                end
            end

        elseif command == 'kick' then
            if #args == 3 then
                local user_id = vRP.getUserId({tonumber(args[2])})
                local reason = args[3]

                if user_id and reason then
                    DropPlayer(user_id, reason)
                    CancelEvent()
                else
                    print('[STORY_CM] [!] 대상자가 접속 중이지 않거나 값이 잘못되었습니다.')
                end
            end
        elseif command == 'ban' then
            if #args == 3 then
                local user_id = vRP.getUserId({tonumber(args[2])})
                local reason = args[3]

                if user_id and reason then
                    vRP.ban({user_id, reason})
                    CancelEvent()
                else
                    print('[STORY_CM] [!] 대상자가 접속 중이지 않거나 값이 잘못되었습니다.')
                end
            end
        else
            print('[STORY_CM] [!] 지정되지 않은 명령어입니다.')
        end
    end
end)