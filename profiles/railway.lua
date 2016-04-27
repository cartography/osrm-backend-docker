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
    if limit ~= nil and limit > 0 then
      if limit < speed then
        return limit        -- stop at first speedlimit that's smaller than speed
      end
    end
  end
  return speed
end

function node_function (node)
end

function way_function (way)
  local railway = way:get_value_by_key("railway")
  local service = way:get_value_by_key("service")
  local usage = way:get_value_by_key("usage")

  if not (railway and railway ~= "")  then
   return
  end

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

  local name = way:get_value_by_key("name")
  local oneway = way:get_value_by_key("oneway")
  if oneway and "reversible" == oneway then
    return
  end

  way.name = name

  local speed_forw = speed_profile[railway] or speed_profile['default']
  local speed_back = speed_forw

  way.speed = speed_forw
  if speed_back ~= way_forw then
    way.backward_speed = speed_back
  end


  way.type = 1
  return 1

end
