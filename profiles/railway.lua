-- Railway profile
-- Found on http://flexnst.ru/2015/11/20/osrm-railway-profile/

speed_profile = {
  ["default"] = 70,
  ["rail"] = 70,
  ["station"] = 70,
  ["platform"] = 70,
  ["halt"] = 70,
  ["switch"] = 70,
  ["level_crossing"] = 70
}

-- these settings are read directly by osrm

take_minimum_of_speeds  = true
obey_oneway             = true
obey_barriers           = true
use_turn_restrictions   = true
ignore_areas            = true  -- future feature
traffic_signal_penalty  = 7     -- seconds
u_turn_penalty          = 20

function limit_speed(speed, limits)
  -- don't use ipairs(), since it stops at the first nil value
  for i=1, #limits do
    limit = limits[i]
    if limit ~= nil and limit &gt; 0 then
      if limit &lt; speed then
        return limit        -- stop at first speedlimit that's smaller than speed
      end
    end
  end
  return speed
end

function node_function (node)
end

function way_function (way)

 if way.tags:Holds("railway") then

  local railway = way.tags:Find("railway")
  local service = way.tags:Find("service")
  local usage = way.tags:Find("usage")

  -- Если не рельсовый путь
  if railway ~= "rail"  then
    return
  end
  -- Если короткие пути в промзонах
  if service == "spur" then
    return
  end
  -- Если индустриальный, военный или туристический путь
  if usage == "industrial" or usage == "military" or usage == "tourism" then
    return
  end

  local name = way.tags:Find("name")
  local oneway = way.tags:Find("oneway")

  way.name = name

  local speed_forw = speed_profile[railway] or speed_profile['default']
  local speed_back = speed_forw

  way.speed = speed_forw
  if speed_back ~= way_forw then
    way.backward_speed = speed_back
  end

  if oneway == "no" or oneway == "0" or oneway == "false" then
    way.direction = Way.bidirectional
  elseif oneway == "-1" then
    way.direction = Way.opposite
  elseif oneway == "yes" or oneway == "1" or oneway == "true" then
    way.direction = Way.oneway
  else
    way.direction = Way.bidirectional
  end

  way.type = 1
  return 1
 end

end
