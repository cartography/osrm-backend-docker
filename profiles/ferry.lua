-- Ferry profile


speed_profile = {
  ["default"] = 50
}

properties.continue_straight_at_waypoint = true
properties.use_turn_restrictions         = false
properties.traffic_signal_penalty        = 7     -- seconds
properties.u_turn_penalty                = 99999

function node_function (node, result)

end

function way_function (way, result)
  local route = way:get_value_by_key("route")
  local name = way:get_value_by_key("name")

  if route ~= "ferry" then
    return
  end

  if name then
    result.name = name
  end

  
  local speed = speed_profile['default']

  result.forward_speed = speed
  result.backward_speed = speed

  result.name = data.name

  result.forward_mode = mode.ferry
  result.backward_mode = mode.ferry
  
end
