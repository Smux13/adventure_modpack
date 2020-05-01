local green_tnt_explosion_radius = 10 -- nodes
local green_tnt_explosion_delay  =  5 -- seconds
local collect_garbage_treshold = 500 -- MB

math.randomseed(os.time())

local function collect_garbage_if_needed()
  local used_memory_in_mb = collectgarbage("count")/1024
  
  minetest.chat_send_all("Memory usage: "..used_memory_in_mb.." MB")
  
  if used_memory_in_mb > collect_garbage_treshold then
    collectgarbage("collect")
    minetest.chat_send_all("Garbage collected")
  end
end

local function green_tnt_explode(pos)
  minetest.chat_send_all("Exploding green crystal TNT at: "..pos.x..", "..pos.y..", "..pos.z)

  minetest.remove_node(pos) -- remove the exploded TNT
  
  minetest.sound_play("tnt_explode", {pos = pos}, true)
  
  collect_garbage_if_needed()
  
  -- make smoke particles
  minetest.add_particlespawner({
    amount = 700,
    time = 1,
    minexptime = 1,
    maxexptime = 3,
    minpos = {x = pos.x-green_tnt_explosion_radius, y = pos.y-green_tnt_explosion_radius, z = pos.z-green_tnt_explosion_radius},
    maxpos = {x = pos.x+green_tnt_explosion_radius, y = pos.y+green_tnt_explosion_radius, z = pos.z+green_tnt_explosion_radius},
    minsize = green_tnt_explosion_radius/2,
    maxsize = green_tnt_explosion_radius*2,
    minvel = {x = -10, y = -10, z = -10},
    maxvel = {x = 10, y = 10, z = 10},
    minacc = {x = 0, y = 0, z = 0},
    maxacc = {x = 0, y = 0, z = 0},
    texture = "tnt_smoke.png",
  })

  collect_garbage_if_needed()

  for radius = 1, green_tnt_explosion_radius do -- grow the hole
    for px = -radius, radius do
      for py = -radius, radius do
        for pz = -radius, radius do
          
          local currentPos = {x = pos.x+px, y = pos.y+py, z = pos.z+pz}
          
          minetest.after(radius/10, function() -- grow the hole, don't remove the nodes immediately
            if minetest.get_node(currentPos).name == "green_crystal:green_crystal_tnt" then -- if the current node is a green tnt
              green_tnt_explode(currentPos) -- explode it
            elseif math.random() > 0.1 then -- if not a green tnt, remove node but not always
              if radius == green_tnt_explosion_radius then -- if this is the last iteration
                if math.random() > 0.2 and minetest.get_node(currentPos).name ~= "green_crystal:green_crystal_tnt_burning" then -- and the current node is not a burning green TNT
                  minetest.dig_node(currentPos) -- dig the node (remove and drop the item)
                end
              else
                minetest.remove_node(currentPos) -- remove the node
              end
            --elseif math.random() > 0.98 then
            --  minetest.spawn_falling_node(currentPos) -- make falling some of the not destructed blocks
            end
            
            node_under_current = minetest.get_node({x = currentPos.x, y = currentPos.y-1, z = currentPos.z})
            if (radius == green_tnt_explosion_radius) and -- if this is the last iteration
                math.random() > 0.995 and -- randomize
                -- if the node under the current is not an another flame, not air and not an ignore node
                (node_under_current.name ~= "default:air") and (node_under_current.name ~= "fire:basic_flame") and (node_under_current.name ~= "ignore") then
              minetest.swap_node(currentPos, {name = "fire:basic_flame"}) -- place a flame
            end
          end)
        end
      end
    end
  end
  
  minetest.chat_send_all("Green Crystal TNT exploded")
  
  collect_garbage_if_needed()
  
  local objects = minetest.get_objects_inside_radius(pos, green_tnt_explosion_radius)
  
  for _, object in pairs(objects) do
    object:set_hp(object:get_hp()-5) -- damage objects inside the radius
  end
end

local function green_tnt_explode_delayed(pos)
  minetest.chat_send_all("Delay: "..green_tnt_explosion_delay)
  minetest.after(green_tnt_explosion_delay, function()
      green_tnt_explode(pos)
    end)
end

local function green_tnt_replace_with_burning(pos)
  minetest.chat_send_all("Green Crystal TNT is burning")
  minetest.swap_node(pos, {name = "green_crystal:green_crystal_tnt_burning"})
  minetest.sound_play("tnt_ignite", {pos = pos}, true)
end

local function green_tnt_check_if_activate(pos, node, puncher)
  --minetest.chat_send_all("TIME SET, REMOVE THIS AFTER TESTING")
  --minetest.set_timeofday(0.5)
  
  minetest.chat_send_all(puncher:get_player_name().." punched a Green TNT")

  wielded_item_name = puncher:get_wielded_item():get_name()

  if (wielded_item_name == "default:torch") then
    green_tnt_replace_with_burning(pos)
    
    green_tnt_explode_delayed(pos)
  end
end

local function after_place_green_tnt(pos, placer, itemstack, pointed_thing)
  minetest.chat_send_all("Green Crystal TNT placed")
  
  minetest.add_particlespawner({
    amount = 100,
    time = 1,
    minexptime = 1,
    maxexptime = 3,
    minpos = {x = pos.x-5, y = pos.y-5, z = pos.z-5},
    maxpos = {x = pos.x+5, y = pos.y+5, z = pos.z+5},
    minsize = 3,
    maxsize = 6,
    minvel = {x = -1, y = -1, z = -1},
    maxvel = {x = 1, y = 1, z = 1},
    minacc = {x = 0, y = 0, z = 0},
    maxacc = {x = 0, y = 0, z = 0},
    texture = "tnt_smoke.png",
  })
end

-- the green crystal item
minetest.register_craftitem("green_crystal:green_crystal", {
  description = "Green Crystal",
  inventory_image = "green_crystal_green_crystal.png",
})

minetest.register_node("green_crystal:green_crystal_block", {
  description = "Green Crystal Block",
  tiles = {"green_crystal_green_crystal_block.png"},
  groups = {cracky = 1},
  drawtype = "allfaces",
  paramtype = "light",
  sounds = default.node_sound_stone_defaults(),
  makes_footstep_sound = true,
})

minetest.register_node("green_crystal:green_crystal_ore", {
  description = "Green Crystal Ore",
  tiles = {"green_crystal_green_crystal_ore.png"},
  groups = {cracky = 3},
  drop = "green_crystal:green_crystal",
  sounds = default.node_sound_stone_defaults(),
  makes_footstep_sound = true,
})

minetest.register_node("green_crystal:green_crystal_tnt", {
  description = "Green Crystal TNT",
  tiles = {
    "green_crystal_green_crystal_tnt_top.png",
    "green_crystal_green_crystal_tnt_bottom.png",
    "green_crystal_green_crystal_tnt_side.png",
    "green_crystal_green_crystal_tnt_side.png",
    "green_crystal_green_crystal_tnt_side.png",
    "green_crystal_green_crystal_tnt_side.png"
  },
  groups = {oddly_breakable_by_hand = 3, tnt = 1},
  on_punch = green_tnt_check_if_activate,
  after_place = after_place_green_tnt,
  on_ignite = function(pos, igniter)
    green_tnt_replace_with_burning(pos)
    green_tnt_explode_delayed(pos)
  end,
  sounds = default.node_sound_wood_defaults(),
  makes_footstep_sound = true,
})

minetest.register_node("green_crystal:green_crystal_tnt_burning", {
  description = "Burning Green Crystal TNT (used internally)",
  tiles = {
    "green_crystal_green_crystal_tnt_top_burning.png",
    "green_crystal_green_crystal_tnt_bottom.png",
    "green_crystal_green_crystal_tnt_side.png",
    "green_crystal_green_crystal_tnt_side.png",
    "green_crystal_green_crystal_tnt_side.png",
    "green_crystal_green_crystal_tnt_side.png"
  },
  groups = {
    not_in_creative_inventory = 1, -- don't display it in the creative inventory
    immortal = 1 -- can't be broken
  },
  light_source = 10, -- make it glowing
  drop = "", -- don't drop anything
})
