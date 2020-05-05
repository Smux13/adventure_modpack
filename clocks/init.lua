function clocks_send_time_to_chat(player, pos)
  local time = minetest.get_timeofday()
  local time_as_mins = minetest.get_timeofday()*24*60

  minetest.chat_send_player(
      player:get_player_name(),
      "The current time is: "..
      string.format("%.0f", time_as_mins/60)..
      ":"..
      string.format("%.0f", time_as_mins%60))
end

minetest.register_node("clocks:clock", {
  description = "Clock",
  tiles = {
    "clocks_clock_base.png^clocks_arrow_minutes.png^clocks_arrow_hours.png",
    "clocks_clock_base.png^clocks_arrow_minutes.png^clocks_arrow_hours.png",
    "clocks_clock_base.png^clocks_arrow_minutes.png^clocks_arrow_hours.png",
    "clocks_clock_base.png^clocks_arrow_minutes.png^clocks_arrow_hours.png"},
  drawtype = "nodebox",
  groups = {oddly_breakable_by_hand = 1},
  on_rightclick = function(pos, node, clicker, itemstack, pointed)
      clocks_send_time_to_chat(clicker, pos)
    end,
  on_punch = function(pos, node, puncher, pointed)
      clocks_send_time_to_chat(puncher, pos)
    end,
})


minetest.register_craft({
  output = "clocks:clock",
  recipe = {
    {"group:wood",  "group:wood",         "group:wood"},
    {"group:wood",  "default:gold_ingot", "group:wood"},
    {"group:wood",  "group:wood",         "group:wood"},
  }
})
