-- Railway profile


speed_profile = {
  ["default"] = 0,
  ["subway"] = 0,
  ["tram"] = 0,
  ["rail"] = 50,
}

properties.continue_straight_at_waypoint = true
properties.use_turn_restrictions         = true
properties.traffic_signal_penalty        = 7     -- seconds
properties.u_turn_penalty                = 99999

function node_function (node, result)
end

function way_function (way, result)
  local railway = way:get_value_by_key("railway")
  local name = way:get_value_by_key("name")

  if railway == nil or railway == "" then
    return
  end

  if name then
    result.name = name
  end

  result.forward_mode = mode.route
  result.backward_mode = mode.route
  
  local speed = speed_profile[railway] or speed_profile['default']

  result.forward_speed = speed
  result.backward_speed = speed
  
end