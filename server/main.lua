---@param name string
---@return table { isProfanity: boolean, flaggedFor: string }
local function isProfane(name)
  local prom = promise.new()

  PerformHttpRequest('https://vector.profanity.dev', function(err, response)
    if err ~= 200 then
      prom:resolve({
        isProfanity = false,
        flaggedFor = ''
      })
    end

    local data = json.decode(response)

    prom:resolve({
      isProfanity = data.isProfanity,
      flaggedFor = data.flaggedFor
    })
  end, 'POST', json.encode({ message = name .. " a" }), { ['Content-Type'] = 'application/json' })

  return Citizen.Await(prom)
end

---@param name string
---@param deferrals table
AddEventHandler('playerConnecting', function(name, _, deferrals)
  deferrals.defer()

  deferrals.update('Checking for profanity...')

  local profanity = isProfane(name)

  if profanity.isProfanity then
    return deferrals.done('Profanity is not allowed in your name. You are flagged for: ' .. profanity.flaggedFor)
  end

  deferrals.done()
end)