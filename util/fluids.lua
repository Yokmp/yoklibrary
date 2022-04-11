
local autofill = false --settings.startup["yfluid-mixer-allow-barreling"].value --TODO or just default to false?

---Creates a molten fluid from an ore.
---@param ore_name any
function make_molten_fluid(ore_name)
  local icon = icons[ore_name] and {icons:get(ore_name)} or get_composed_icon(ore_name)
  data:extend({{
    type = "fluid",
    name = "molten-"..ore_name,
    localised_name = {"", {"item-name.molten"}, " ", {"item-name."..ore_name}},
    icons = icon,
    default_temperature = yutil.ore_definition(ore_name).min,
    max_temperature = yutil.ore_definition(ore_name).max,
    heat_capacity = "0.425KJ",
    base_color = yutil.color.moltenmetal.base,
    flow_color = yutil.color.moltenmetal.flow,
    order = "m[molten-"..ore_name.."]",
    auto_barrel = autofill
  }})
end



---Creates a new fluid from 2 existing ones
---@param fluid_a string
---@param fluid_b string
function new_mixed_fluid(fluid_a, fluid_b)
  local fluid_name = fluid_a.."-"..fluid_b.."-mix"
  local temp_min = math.min(data.raw.fluid[fluid_a].default_temperature, data.raw.fluid[fluid_b].default_temperature)
  local temp_max = math.max(data.raw.fluid[fluid_a].max_temperature or temp_min, data.raw.fluid[fluid_b].max_temperature or temp_min)
  local icon_base = get_fluid_icon(fluid_a)
  local icon_mix = get_fluid_icon(fluid_b)
  icon_base.shift = {-6,-4}
  icon_mix.shift = {6,-4}


  local mixed_fluid = {
    type = "fluid",
    name = fluid_name,
    localised_name = {"", {"fluid-name."..fluid_a}, "-", {"fluid-name."..fluid_b}, " ", {"fluid-name.mix"}},
    icons = {icon_base, icon_mix, icons:get("fluid_mixing")},
    default_temperature = temp_min,
    max_temperature = temp_max,
    heat_capacity = "0.425KJ",
    base_color = mix_tints(data.raw.fluid[fluid_a].base_color, data.raw.fluid[fluid_b].base_color),
    flow_color = mix_tints(data.raw.fluid[fluid_a].flow_color, data.raw.fluid[fluid_b].flow_color),
    order = "mx["..fluid_name.."]",
    allow_decomposition = false,
    auto_barrel = autofill
  }
  data:extend({mixed_fluid})
end
-- new_mixed_fluid("crude-oil", "heavy-oil")
-- log(serpent.block(data.raw.fluid["crude-oil-heavy-oil-mix"]))
-- error("new_mixed_fluid()")


---Takes in 2 existing fluids and creates a recipe which result is a mixture of both
---@param fluid_a string
---@param fluid_b string
---@param enabled boolean
---@param category string
---@param energy number
function new_fluid_mix_recipe(fluid_a, fluid_b, enabled, category, energy)
  local data_a = data.raw.fluid[fluid_a]
  local data_b = data.raw.fluid[fluid_b]
  local temp_a = data_a.default_temperature
  local temp_b = data_b.default_temperature
  local temp_mix = (temp_a + temp_b)/2

data:extend({
  {
    type = "recipe",
    name = fluid_a.."-"..fluid_b.."-mix",
    category = category or "chemistry", --//TODO change to fluid mixer category
    enabled = enabled or false,
    energy_required = energy or nil,
    allow_decomposition = false,
    crafting_machine_tint =
    {
      primary = data_a.base_color, -- fluid
      secondary = data_b.base_color, -- foam
      tertiary = data_a.base_color, -- smoke inner
      quaternary = data_b.base_color, -- smoke outer
    },
    ingredients = {
      {type="fluid", name=fluid_a, amount=20},
      {type="fluid", name=fluid_b, amount=20}
    },
    results = {
      {type = "fluid", name = fluid_a.."-"..fluid_b.."-mix", amount = 40, temperature = temp_mix}
    },
  },
})
end
-- new_fluid_mix_recipe("crude-oil", "heavy-oil", true, "chemistry")
-- log(serpent.block(data.raw.recipe["crude-oil-heavy-oil-mix"]))
-- error("new_fluid_mix_recipe()")


---Creates a separation recipe for the 2 given fluids
---@param fluid_a string
---@param fluid_b string
---@param enabled boolean
---@param category string
---@param energy number
function new_fluid_separation_recipe(fluid_a, fluid_b, enabled, category, energy)
  local mix_recipe = data.raw.recipe[fluid_a.."-"..fluid_b.."-mix"]
  local icon_base = get_fluid_icon(fluid_a)
  local icon_mix = get_fluid_icon(fluid_b)
  local icon_filter = icons:get("filter")
  icon_filter.scale = icon_filter.scale
  icon_base.scale = icon_base.scale/1.5
  icon_base.shift = {-8, 8}
  icon_mix.scale = icon_mix.scale/1.5
  icon_mix.shift = {8, 8}
  category = category or "oil-processing"
  -- if mix_recipe.category == "chemistry" then
  --   category = "oil-processing"
  -- end

  data:extend({
    {
      type = "recipe",
      name = fluid_a.."-"..fluid_b.."-separation",
      icons = {icons:get("filter"), icon_base, icon_mix},
      localised_name = {"", {"fluid-name."..fluid_a}, "-", {"fluid-name."..fluid_b}, " ", {"fluid-name.separation"}},
      category = category or mix_recipe.category, --//TODO change to fluid mixer category
      enabled = enabled or mix_recipe.enabled,
      energy_required = energy or mix_recipe.energy,
      subgroup = "fluid-recipes",
      allow_decomposition = false,
      crafting_machine_tint = mix_recipe.crafting_machine_tint,
      ingredients = mix_recipe.results,
      results = mix_recipe.ingredients
    },
  })
end


---Returns a list of all fluids
---@param filter? table
---@return table
function get_fluids(filter)
  filter = filter or {""}
  local list = {}
  for _, fluid in pairs(data.raw.fluid) do
    for _, f in ipairs(filter) do
      if string.find(fluid.name, f) then
        list[#list+1] = fluid.name
      end
    end
  end
  return list
end


--TODO finish this and find a use case for mixed fluids i guess


function set_fluid_mix_ingredient(fluid_a, fluid_b)
  local mix_name = fluid_a.."-"..fluid_b.."-mix"
  local recipe_list = {get_recipes_byingredient(fluid_a), get_recipes_byingredient(fluid_b)}
  local matches = get_table_matches(recipe_list[1], recipe_list[2])

  for _, recipe_name in ipairs(matches) do
    if not string.find(recipe_name, "-mix") then

    local amount_a = get_recipe_amount_in(recipe_name, fluid_a)
    local amount_b = get_recipe_amount_in(recipe_name, fluid_b)
    -- local amount_in = { math.max(amount_a[1], amount_b[1]), math.max(amount_a[2], amount_b[2]) }

     -- just get the mean as the result function isnt finished
    local amount_in = { (amount_a[1] + amount_b[1]) /2, (amount_a[2] + amount_b[2]) /2 }
    bobmods.lib.recipe.remove_ingredient(recipe_name, fluid_a)
    bobmods.lib.recipe.remove_ingredient(recipe_name, fluid_b)

    recipe_add_ingredient(recipe_name, mix_name, amount_in)
    end
  end

  return matches
end
-- new_mixed_fluid("crude-oil", "water")
-- log(serpent.block(data.raw.recipe[ set_fluid_mix_ingredient("crude-oil", "water")[1] ]))
-- error("set_fluid_mix_ingredient()")


-- function set_fluid_mix_results(fluid_a, fluid_b) --TODO this will be a big mess as there is so much to check
--   local mix_name = fluid_a.."-"..fluid_b.."-mix"
--   local recipe_list = {get_recipes_byingredient(fluid_a), get_recipes_byingredient(fluid_b)}
--   local matches = get_table_matches(recipe_list[1], recipe_list[2])

--   for _, recipe_name in ipairs(matches) do
--     if not string.find(recipe_name, "-mix") then

--       local amount_a = get_recipe_amount_in(recipe_name, fluid_a)
--       local amount_b = get_recipe_amount_in(recipe_name, fluid_b)
--       local amount_out = { math.max(amount_a[1], amount_b[1]), math.max(amount_a[2], amount_b[2]) }

--       local leftover = {
--         {
--           name = amount_a[1] == math.min(amount_a[1], amount_b[1]) and fluid_a or fluid_b,
--           amount = amount_out[1] - math.min(amount_a[1], amount_b[1])
--         },
--         {
--           name = amount_a[1] == math.min(amount_a[1], amount_b[1]) and fluid_a or fluid_b,
--           amount = amount_out[2] - math.min(amount_a[2], amount_b[2])
--         }
--       }


-- -- if there are more results than the machine can handle
-- -- first get the recipe category (Default: "crafting")
-- -- advanced-crafting
-- -- basic-crafting
-- -- centrifuging
-- -- chemistry
-- -- crafting
-- -- crafting-with-fluid
-- -- oil-processing
-- -- rocket-building
-- -- smelting
-- -- get every machine with that category and check the fluid_boxes
-- -- loop over that list to get the entity_name


-- --If there are enough fluid_boxes for an additional output
--       -- ---@type integer
--       -- local fluidbox_types = get_fluid_box_types(entity_name).output
--       -- local result_count = 0
--       -- for _, value in pairs( get_recipe_result_count(recipe_name, "fluid") ) do
--       --   result_count = result_count < value and value or result_count
--       -- end
--       -- if fluidbox_types < result_count then
--       --   if (leftover[1].amount + leftover[2].amount) > 0 then
--       --     recipe_add_result(recipe_name, leftover[1].name, {leftover[1].amount, leftover[2].amount})
--       --   end
--       -- end



--     end
--   end
--   return matches
-- end
-- new_mixed_fluid("crude-oil", "water")
-- log(serpent.block(data.raw.recipe[ set_fluid_mix_results("crude-oil", "water")[1] ]))
-- error("set_fluid_mix_results()")


---Wrapper function. Gets all fluid types and creates mixed fluids and recipes
---@param pattern table
function new_mixed_fluids_and_recipes(pattern)
  local list = get_fluids(pattern)
  for index, base in pairs(list) do
    for i = index, #list, 1 do
      if base ~= list[i] then
        new_mixed_fluid(base, list[i])
        new_fluid_mix_recipe(base, list[i], true)
        new_fluid_separation_recipe(base, list[i], true)
        -- set_fluid_mix_results(base, list[i])
        set_fluid_mix_ingredient(base, list[i])
      end
    end
    index = index + 2 --just create duplicates but set them as hidden and the result to the same?
  end
end


