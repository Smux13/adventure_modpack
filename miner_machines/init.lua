--[[
Miner Machines mod for Minetest
]]--

local miner_machine_iron_delay    = 4
local miner_machine_gold_delay    = 2
local miner_machine_diamond_delay = 1
local miner_machine_mese_delay    = 0.5

function miner_machine_dig_recursive(pos, delay)
  local current_node_name = minetest.get_node(pos).name
  if current_node_name ~= "miner_machines:miner_machine_iron"   and
    current_node_name ~= "miner_machines:miner_machine_gold"    and
    current_node_name ~= "miner_machines:miner_machine_diamond" and
    current_node_name ~= "miner_machines:miner_machine_mese"    then
    return
  end
  
    minetest.add_particlespawner({
    amount = 300,
    time = 1,
    minexptime = 1,
    maxexptime = 3,
    minpos = {x = pos.x-1, y = pos.y-1, z = pos.z-1},
    maxpos = {x = pos.x+1, y = pos.y+1, z = pos.z+1},
    minsize = 0.5,
    maxsize = 3,
    minvel = {x = -0.5, y = 2, z = -0.5},
    maxvel = {x = 0.5, y = 2, z = 0.5},
    minacc = {x = 0, y = 0, z = 0},
    maxacc = {x = 0, y = 0, z = 0},
    texture = "miner_machines_machine_smoke.png",
  })

  minetest.sound_play("default_dug_node", {
    pos = pos,
    max_hear_distance = 20,
    gain = 0.5,
  })
  
  minetest.chat_send_all("Digging")
  
  local pos_under_machine = {x = pos.x, y = pos.y-1, z = pos.z}
  
  minetest.dig_node(pos_under_machine)
  
  minetest.after(delay, function()
    miner_machine_dig_recursive(pos_under_machine, delay)
  end)
end

function after_place_miner_machine(pos, delay)
  minetest.chat_send_all("Miner Machine placed at: "..pos.x.." "..pos.y.." "..pos.z.." ".." Delay: "..delay)
  
  minetest.after(delay, function()
    miner_machine_dig_recursive(pos, delay)
  end)
end

minetest.register_node("miner_machines:miner_machine_iron", {
  description = "Iron Miner Machine",
  tiles = {
    "miner_machines_miner_machine_top.png",
    "miner_machines_miner_machine_iron_bottom.png",
    "miner_machines_miner_machine_iron_side.png",
    "miner_machines_miner_machine_iron_side.png",
    "miner_machines_miner_machine_iron_side.png",
    "miner_machines_miner_machine_iron_side.png",
  },
  drawtype = "nodebox",
  groups = {cracky = 1, falling_node = 1},
  after_place_node = function(pos, placer)
    after_place_miner_machine(pos, miner_machine_iron_delay)
  end,
  sounds = default.node_sound_metal_defaults(),
  makes_footstep_sound = true,
})

minetest.register_node("miner_machines:miner_machine_gold", {
  description = "Gold Miner Machine",
  tiles = {
    "miner_machines_miner_machine_top.png",
    "miner_machines_miner_machine_gold_bottom.png",
    "miner_machines_miner_machine_gold_side.png",
    "miner_machines_miner_machine_gold_side.png",
    "miner_machines_miner_machine_gold_side.png",
    "miner_machines_miner_machine_gold_side.png",
  },
  drawtype = "nodebox",
  groups = {cracky = 1, falling_node = 1},
  after_place_node = function(pos, placer)
    after_place_miner_machine(pos, miner_machine_gold_delay)
  end,
  sounds = default.node_sound_metal_defaults(),
  makes_footstep_sound = true,
})

minetest.register_node("miner_machines:miner_machine_diamond", {
  description = "Diamond Miner Machine",
  tiles = {
    "miner_machines_miner_machine_top.png",
    "miner_machines_miner_machine_diamond_bottom.png",
    "miner_machines_miner_machine_diamond_side.png",
    "miner_machines_miner_machine_diamond_side.png",
    "miner_machines_miner_machine_diamond_side.png",
    "miner_machines_miner_machine_diamond_side.png",
  },
  drawtype = "nodebox",
  groups = {cracky = 1, falling_node = 1},
  after_place_node = function(pos, placer)
    after_place_miner_machine(pos, miner_machine_diamond_delay)
  end,
  sounds = default.node_sound_metal_defaults(),
  makes_footstep_sound = true,
})

minetest.register_node("miner_machines:miner_machine_mese", {
  description = "Mese Miner Machine",
  tiles = {
    "miner_machines_miner_machine_top.png",
    "miner_machines_miner_machine_mese_bottom.png",
    "miner_machines_miner_machine_mese_side.png",
    "miner_machines_miner_machine_mese_side.png",
    "miner_machines_miner_machine_mese_side.png",
    "miner_machines_miner_machine_mese_side.png",
  },
  drawtype = "nodebox",
  groups = {cracky = 1, falling_node = 1},
  after_place_node = function(pos, placer)
    after_place_miner_machine(pos, miner_machine_mese_delay)
  end,
  sounds = default.node_sound_metal_defaults(),
  makes_footstep_sound = true,
})

minetest.register_craftitem("miner_machines:gear", {
  description = "Gear",
  inventory_image = "miner_machines_gear.png",
})

minetest.register_craft({
  output = "miner_machines:gear",
  recipe = {
    {"",                    "default:steel_ingot",      ""},
    {"default:steel_ingot", "",                         "default:steel_ingot"},
    {"",                    "default:steel_ingot",      ""},
  },
})

minetest.register_craft({
  output = "miner_machines:miner_machine_iron",
  recipe = {
    {"default:steel_ingot",   "default:steel_ingot",    "default:steel_ingot"},
    {"default:steel_ingot",   "miner_machines:gear",    "default:steel_ingot"},
    {"",                      "default:steelblock",     ""},
  }
})

minetest.register_craft({
  output = "miner_machines:miner_machine_gold",
  recipe = {
    {"default:steel_ingot",   "default:steel_ingot",    "default:steel_ingot"},
    {"default:steel_ingot",   "miner_machines:gear",    "default:steel_ingot"},
    {"",                      "default:goldblock",      ""},
  }
})

minetest.register_craft({
  output = "miner_machines:miner_machine_diamond",
  recipe = {
    {"default:steel_ingot",   "default:steel_ingot",    "default:steel_ingot"},
    {"default:steel_ingot",   "miner_machines:gear",    "default:steel_ingot"},
    {"",                      "default:diamondblock",   ""},
  }
})

minetest.register_craft({
  output = "miner_machines:miner_machine_mese",
  recipe = {
    {"default:steel_ingot",   "default:steel_ingot",    "default:steel_ingot"},
    {"default:steel_ingot",   "miner_machines:gear",    "default:steel_ingot"},
    {"",                      "default:mese",           ""},
  }
})