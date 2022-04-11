
local use_slag = settings.startup["ymm-enable-slag"].value


---Creates a smelting recipe, _ore-name_ to _molten-ore-name_
---@param ore_name string also determines the main product
---@param amount_in? table {normal, expensive}
---@param amount_out? table {normal, expensive}
---@param energy? table {normal, expensive}
---@param enabled? table {normal, expensive}
function new_smelting_recipe_ext(ore_name, amount_in, amount_out, energy, enabled)
  amount_in = amount_in or {2,2}
  amount_out = amount_out or {40,40}
  energy = energy or {0.5,0.5} --{3.2,3.2}
  enabled = enabled or {false, false}
  local temperature = yutil.ore_definition(ore_name).min
  -- info("New molten-"..ore_name.." {"..amount_in[1]..", "..amount_in[2].."},".." {"..amount_out[1]..", "..amount_out[2].."}")

  local recipe =  {
    type = "recipe",
    name = "molten-"..ore_name,
    localised_name = {"", {"item-name."..ore_name}, " ", {"item-name.smelting"}},
    category = categories.smelting,
    allow_as_intermediate = false,
    allow_intermediates = false,
    hidden = false,
    hide_from_player_crafting = true,
    show_amount_in_title = true,
    always_show_products = true,
    order = "m[molten-"..ore_name.."]",
    crafting_machine_tint = yutil.color.moltenmetal.tint,
    normal = {
      main_product = "molten-"..ore_name,
      enabled = enabled[1],
      energy_required = energy[1],
      ingredients = {
        {type = "item", name = ore_name, amount = amount_in[1]}
      },
      results = {
        {type = "fluid", name = "molten-"..ore_name, amount = amount_out[1], temperature = temperature}
      }
    },
    expensive = {
      main_product = "molten-"..ore_name,
      enabled = enabled[2],
      energy_required = energy[2],
      ingredients = {
        {type = "item", name = ore_name, amount = amount_in[2]}
      },
      results = {
        {type = "fluid", name = "molten-"..ore_name, amount = amount_out[2], temperature = temperature}
      }
    }
  }
  if use_slag then
    local slag_normal = {type = "item", name = "slag-stone", amount_min = 1, amount_max = math.floor(amount_out[1]/10), probability = 0.24}
    local slag_expensive = {type = "item", name = "slag-stone", amount_min = 1, amount_max = math.floor(amount_out[2]/10), probability = 0.24}
    table.insert(recipe.normal.results, slag_normal)
    table.insert(recipe.expensive.results, slag_expensive)
  end

  data:extend({recipe})
end
-- make_new_smelting_recipe( "iron-ore", {2,2}, {40,40}, {3.2,3.2})
-- log(serpent.block(data.raw.recipe["molten-iron"]))
-- make_new_smelting_recipe( "iron-ore")
-- log(serpent.block(data.raw.recipe["molten-iron-ore"]))
-- error("make_new_smelting_recipe()")

---Wrapper for new_smelting_recipe_ext()
---@param ore_name string ingredient
---@param recipe_name string the recipe used to calculate the input amount
---@param result? string must be set if recipe and result names differ; used to calc the output amount
---@param enabled? boolean
---@param multiplier? number 3 - applied to ingredients and results
function new_smelting_recipe(ore_name, recipe_name, result, enabled, multiplier) --BUG needs result to calc amount
  multiplier = multiplier or 3
  result = result or recipe_name
  local amount_in = recipe_get_amount_in(recipe_name, ore_name)
  local amount_out = recipe_get_amount_out(recipe_name, result)
  amount_in[1] = amount_in[1]*(2*multiplier) -- ratio is 1:20
  amount_in[2] = amount_in[2]*(2*multiplier)
  amount_out[1] = amount_out[1]*(40*multiplier)
  amount_out[2] = amount_out[2]*(40*multiplier)

  info("new smelting recipe: molten-"..ore_name.." for: "..result)
  new_smelting_recipe_ext( ore_name, amount_in, amount_out, recipe_get_energy_required(recipe_name), enabled or false)
end


---Creates a new casting recipe
---@param fluid_name string ``"molten-"..fluid_name`` recipe and ingredient name (molten-result-name)
---@param result_name string also sets the main product, must be an item
---@param amount_in? table ``{normal, expensive} or {20,20}``
---@param amount_out? table ``{normal, expensive} or (recipe_get_amount_out(result_name) or {1,1})``
---@param energy? table ``{normal, expensive} or {0.5,0.5}``
---@param enabled? table ``{normal, expensive} or false``
function new_casting_recipe_ext(fluid_name, result_name, amount_in, amount_out, energy, enabled)
  amount_in = amount_in or {20,20}
  amount_out = amount_out or (recipe_get_amount_out(result_name) or {1,1})
  energy = energy or {0.5,0.5} --vanilla default
  enabled = enabled or {false, false}
  temperature = yutil.ore_definition(fluid_name).min
  -- info("New "..fluid_name.." casting".." {"..amount_in[1]..", "..amount_in[2].."}"..
  -- " into "..result_name.." {"..amount_out[1]..", "..amount_out[2].."}")

data:extend({{
  type = "recipe",
  name = "molten-"..result_name,
  localised_name = {"", {"item-name."..result_name}, " ", {"item-name.casting"}},
  category = categories.casting,
  show_amount_in_title = true,
  allow_as_intermediate = false,
  allow_intermediates = false,
  hidden = false,
  hide_from_player_crafting = true,
  always_show_products = true,
  order = "m[molten-"..result_name.."]",
  crafting_machine_tint = yutil.color.moltenmetal.tint,
  normal = {
    main_product = result_name,
    enabled = enabled[1],
    energy_required = energy[1], -- 1.6 (3.2 at speed 2)
    ingredients = {
      {type = "fluid", name = "molten-"..fluid_name, amount = amount_in[1], temperature = temperature},
      {type = "fluid", name = "water", amount = math.floor((amount_in[1]*1.8)/10)*10}
    },
    results = {
      {type = "item",  name = result_name, amount = amount_out[1]},
      -- {type = "fluid", name = "steam", amount = amount_in[1]*2.5, temperature = 165}
      {type = "fluid", name = "steam", amount = 12, temperature = 165}
    }
  },
  expensive = {
    main_product = result_name,
    enabled = enabled[2],
    energy_required = energy[2],
    ingredients = {
      {type = "fluid", name = "molten-"..fluid_name, amount = amount_in[2], temperature = temperature},
      {type = "fluid", name = "water", amount = math.ceil(amount_in[1]*2.2)}
    },
    results = {
      {type = "item",  name = result_name, amount = amount_out[2]},
      -- {type = "fluid", name = "steam", amount = amount_in[1]*3.75, temperature = 165}
      {type = "fluid", name = "steam", amount = 6, temperature = 165}
    }
  }
}})
end
-- make_new_casting_recipe("iron-ore", "iron-plate", {20,20}, {1,1}, {1.6,1.6})
-- log(serpent.block(data.raw.recipe["molten-iron-plate"]))
-- make_new_casting_recipe("iron-ore", "iron-plate")
-- log(serpent.block(data.raw.recipe["molten-iron-plate"]))
-- error("make_new_smelting_recipe()")

---Wrapper for new_casting_recipe_ext()
---@param ore_name string ore-name, __NOT__ fluid-name
---@param ingredient string defines input amount
---@param result string item-name, also defines output amount
---@param multiplier? table ``{3,3}`` - applied to ingredients[1] and results[2]
function new_casting_recipe(ore_name, ingredient, result, multiplier)
  multiplier = multiplier or {3,3}
  local energy = recipe_get_energy_required(result)
  local amount_in = recipe_get_amount_in(result, ingredient)
  local amount_out = recipe_get_amount_out(result)
  energy[1] = energy[1]/2 --casting machine speed is 1 and 1.5
  energy[2] = energy[2]/2 --vanilla furnace is 2 (vanilla energy min is 0.5)

  amount_in[1] = amount_in[1] < 20 and (amount_in[1]*20)*multiplier[1] -- if returns 0?
  amount_in[2] = amount_in[2] < 20 and (amount_in[2]*20)*multiplier[1] -- if returns nil?

  amount_out[1] = amount_out[1] < 20 and amount_out[1]*multiplier[2]
  amount_out[2] = amount_out[2] < 20 and amount_out[2]*multiplier[2]

  info("new casting recipe for: "..result)
  new_casting_recipe_ext(ore_name, result, amount_in, amount_out, energy)
end
-- new_casting_recipe("stone", "stone", "stone-brick")
-- log(serpent.block(data.raw.recipe["molten-stone-brick"]))
-- error("new_casting_recipe")



    ------------
    -- HELPER --
    ------------


---Enable or disable a recipe/difficulty
---@param recipe_name string
---@param enabled table contains boolean {normal, expensive}
function recipe_set_enabled(recipe_name, enabled)
  if data.raw.recipe[recipe_name] then
    data.raw.recipe[recipe_name].normal.enabled = enabled[1]
    data.raw.recipe[recipe_name].expensive.enabled = enabled[2]
    if logging then log(recipe_name.." enabled: ".. tostring(enabled[1]) ..", ".. tostring(enabled[2])) end
  else
    log("Unknown recipe: "..tostring(recipe_name))
  end
end
-- recipe_set_enabled("tank", {true,false})
-- log(serpent.block(data.raw.recipe["tank"]))
-- error("recipe_set_enabled()")

---Sets a recipes required energy
---@param recipe_name string
---@param energy table contains float {normal, expensive}
function recipe_set_energy(recipe_name, energy)
  if data.raw.recipe[recipe_name] then
    data.raw.recipe[recipe_name].normal.energy_required = energy[1]
    data.raw.recipe[recipe_name].expensive.energy_required = energy[2]
  else
    log("Unknown recipe: "..tostring(recipe_name))
  end
end
-- recipe_set_energy("tank", {1,1})
-- log(serpent.block(data.raw.recipe["tank"]))
-- error("recipe_set_energy()")

---Sets a recipes ingredient temperature
---@param recipe_name string
---@param temperature table contains integers {normal, expensive}
function recipe_set_ingredient_temperature(recipe_name, temperature)
  if data.raw.recipe[recipe_name] then
    for index, value in ipairs(data.raw.recipe[recipe_name].normal.ingredients) do
      if value.temperature and string.find(value.name, "molten-", 0, true) then
        data.raw.recipe[recipe_name].normal.ingredients[index].temperature = temperature[1]
        data.raw.recipe[recipe_name].expensive.ingredients[index].temperature = temperature[2] -- lets hope theyre the same
      end
    end
  else
    log("Unknown recipe: "..tostring(recipe_name))
  end
end
-- recipe_set_ingredient_temperature("molten-iron-plate", {123,456})
-- log(serpent.block(data.raw.recipe["molten-iron-plate"]))
-- error("recipe_set_ingredient_temperature()")

---Sets a recipes results temperature
---@param recipe_name string
---@param temperature table contains integers {normal, expensive}
function recipe_set_result_temperature(recipe_name, temperature)
  if data.raw.recipe[recipe_name] then
    for index, value in ipairs(data.raw.recipe[recipe_name].normal.results) do
      if value.temperature and string.find(value.name, "molten-", 0, true) then
        data.raw.recipe[recipe_name].normal.results[index].temperature = temperature[1]
        data.raw.recipe[recipe_name].expensive.results[index].temperature = temperature[2] -- lets hope theyre the same
      end
    end
  else
    log("Unknown recipe: "..tostring(recipe_name))
  end
end
-- recipe_set_result_temperature("molten-iron-ore", {123,456})
-- log(serpent.block(data.raw.recipe["molten-iron-ore"]))
-- error("recipe_set_result_temperature()")



---Adds an inredient to a recipe
---@param recipe_name string
---@param ingredient string
---@param amount? table ``{nomral, expensive}``
function recipe_add_ingredient(recipe_name, ingredient, amount)
  amount = amount or {1,1}
  if data.raw.recipe[recipe_name] then
    if type(ingredient) == "string" then
      if data.raw.recipe[recipe_name].ingredients then
        table.insert(data.raw.recipe[recipe_name].ingredients, {name = ingredient, amount = amount[1]})
      end
      if data.raw.recipe[recipe_name].normal and data.raw.recipe[recipe_name].normal.ingredients then
        table.insert(data.raw.recipe[recipe_name].normal.ingredients, {name = ingredient, amount = amount[1]})
      end
      if data.raw.recipe[recipe_name].expensive and data.raw.recipe[recipe_name].expensive.ingredients then
        table.insert(data.raw.recipe[recipe_name].expensive.ingredients, {name = ingredient, amount = amount[2]})
      end
    else
      log("Wrong type: "..type(ingredient))
    end
  else
    log("Recipe "..tostring(recipe_name).." does not exist!")
  end
end
-- recipe_add_ingredient("tank", "TEST", {1,2})
-- log(serpent.block(data.raw.recipe["tank"]))
-- recipe_add_ingredient("gun-turret", "TEST")
-- log(serpent.block(data.raw.recipe["gun-turret"]))
-- error("recipe_add_ingredient()")


---Overwrites the ingredients of the given recipe
---@param recipe_name string
---@param ingredients table ``{ {ingredients}, ... }``
function recipe_set_ingredients(recipe_name, ingredients)
  if data.raw.recipe[recipe_name] then
    if type(ingredients) == "table" then
      if data.raw.recipe[recipe_name].ingredients then
        data.raw.recipe[recipe_name].ingredients = {ingredients}
      end
      if data.raw.recipe[recipe_name].normal and data.raw.recipe[recipe_name].normal then
        data.raw.recipe[recipe_name].normal.ingredients = ingredients
      end
      if data.raw.recipe[recipe_name].expensive then
        data.raw.recipe[recipe_name].expensive.ingredients = ingredients
      end
    else
      log("Wrong type: "..type(ingredients))
    end
  else
    log("Recipe "..tostring(recipe_name).." does not exist!")
  end
end


---Removes an ingredient from the recipe
---@param recipe_name string
---@param ingredient_name string
function recipe_remove_ingredient(recipe_name, ingredient_name)
  if data.raw.recipe[recipe_name] then
    if type(ingredient_name) == "string" then

      local function remove(_t)
        for i, value in ipairs(_t) do
          if (value.name or value[1]) == ingredient_name then
            table.remove(_t, i)
          end
        end
      end

      if data.raw.recipe[recipe_name].ingredients then
        remove(data.raw.recipe[recipe_name].ingredients)
      end
      if data.raw.recipe[recipe_name].normal and data.raw.recipe[recipe_name].normal.ingredients then
        remove(data.raw.recipe[recipe_name].normal.ingredients)
      end
      if data.raw.recipe[recipe_name].expensive and data.raw.recipe[recipe_name].expensive.ingredients then
        remove(data.raw.recipe[recipe_name].expensive.ingredients)
      end

    else
      log("string expected, got "..type(ingredient_name))
    end
  else
    log("Recipe "..tostring(recipe_name).." does not exist!")
  end
end
-- recipe_remove_ingredient("tank", "engine-unit")
-- log(serpent.block(data.raw.recipe["tank"]))
-- recipe_remove_ingredient("gun-turret", "iron-plate")
-- log(serpent.block(data.raw.recipe["gun-turret"]))
-- recipe_remove_ingredient("production-science-pack", "rail")
-- log(serpent.block(data.raw.recipe["production-science-pack"]))
-- error("recipe_remove_ingredient()")


--TODO should only replace the ingredient, NOT the amount

---Replaces an ingredient
---@param recipe_name string
---@param ingredient_remove string
---@param ingredient_add string
function recipe_replace_ingredient(recipe_name, ingredient_remove, ingredient_add)
  if data.raw.recipe[recipe_name] then
    local amount = recipe_get_amount_in(recipe_name, ingredient_remove)
    recipe_remove_ingredient(recipe_name, ingredient_remove)
    recipe_add_ingredient(recipe_name, ingredient_add, amount)
  else
    log("Recipe "..tostring(recipe_name).." does not exist!")
  end
end


---Returns a recipes ingredients by difficulty (if available) or nil
---@param recipe_name string
---@return table|nil
function recipe_get_ingredients(recipe_name)
  if type(recipe_name) == "string" and data.raw.recipe[recipe_name] then
    local data_recipe = data.raw.recipe[recipe_name]
    local ingredients = {}

    if data_recipe.ingredients and data_recipe.ingredients then
      ingredients.ingredients = {}
      for i, ingredient in ipairs(data_recipe.ingredients) do
        ingredients.ingredients[i] = yutil.add_pairs(ingredient)
      end
    end
    if data_recipe.normal and data_recipe.normal.ingredients then
      ingredients.normal = {}
      for i, ingredient in ipairs(data_recipe.normal.ingredients) do
        ingredients.normal[i] = yutil.add_pairs(ingredient)
      end
    end
    if data_recipe.expensive and data_recipe.expensive.ingredients then
      ingredients.expensive = {}
      for i, ingredient in ipairs(data_recipe.expensive.ingredients) do
        ingredients.expensive[i] = yutil.add_pairs(ingredient)
      end
    end
    return ingredients
  else
    log(" Recipe not found: "..tostring(recipe_name))
  end
  return nil
end
-- log(serpent.block(get_recipe_ingredients("tank")))
-- log(serpent.block(get_recipe_ingredients("steel-furnace")))
-- error("get_recipe_ingredients()")


---Returns a list of all recipes using the given ingredient
---@param item_name string
---@param item_type? string
---@return table table List of recipe names
function recipe_get_byingredient(item_name, item_type)
  item_type = item_type or get_type(item_name)
  if data.raw[item_type][item_name] then
    local recipes = {}

    for recipe_name, data_recipe in pairs(data.raw.recipe) do
      if yutil.check_table(data_recipe.ingredients) then
        for _, ingredient in ipairs(data_recipe.ingredients) do
          if ingredient.name and ingredient.name == item_name then table.insert(recipes, recipe_name)
          elseif ingredient[1] and ingredient[1] == item_name then table.insert(recipes, recipe_name)
          end
        end
      end

      if data_recipe.normal then
        if yutil.check_table(data_recipe.normal.ingredients) then
          for _, ingredient in ipairs(data_recipe.normal.ingredients) do
            if ingredient.name == item_name then table.insert(recipes, recipe_name) end
          end
        end
      end

      if data_recipe.expensive then
        if yutil.check_table(data_recipe.expensive.ingredients) then
          for _, ingredient in ipairs(data_recipe.expensive.ingredients) do
            if ingredient.name == item_name then table.insert(recipes, recipe_name) end
          end
        end
      end
    end
  return recipes
  else
    log(" Item not found: "..tostring(item_name))
  end
end
-- log(serpent.block(get_recipes_byingredient("iron-ore")))
-- log(serpent.block(get_recipes_byingredient("uranium-ore")))
-- log(serpent.block(get_recipes_byingredient("copper-plate")))
-- log(serpent.block(get_recipes_byingredient("electric-furnace")))
-- error("get_recipes_byingredient()")


---Returns a table containing the results of the given recipe
---@param recipe_name string
---@return table
function recipe_get_results(recipe_name)
    local _return = {results={}, normal={}, expensive={}}

  if data.raw.recipe[recipe_name] then
    local data_recipe = data.raw.recipe[recipe_name]

    if yutil.check_table(data_recipe.results) then
      for i, result in pairs(data_recipe.results) do
        _return.results[i] = yutil.add_pairs( result )
      end
    elseif data_recipe.result then
      _return.results[1] = yutil.add_pairs( {data_recipe.result, data_recipe.result_count} )
    end

    if data_recipe.normal then
      if yutil.check_table(data_recipe.normal.results) then
        for i, result in pairs(data_recipe.normal.results) do
          _return.normal[i] = yutil.add_pairs( result )
        end
      elseif data_recipe.normal.result then
        _return.normal[1] = yutil.add_pairs( {data_recipe.normal.result, data_recipe.normal.result_count} )
      end
    end

    if data_recipe.expensive then
      if yutil.check_table(data_recipe.expensive.results) then
        for i, result in pairs(data_recipe.expensive.results) do
          _return.expensive[i] = yutil.add_pairs( result )
        end
      elseif data_recipe.expensive.result then
        _return.expensive[1] = yutil.add_pairs( {data_recipe.expensive.result, data_recipe.expensive.result_count} )
      end
    end

  else
    log(" Recipe not found: "..tostring(recipe_name))
  end
  return _return
end
-- log(serpent.block( get_recipe_results( "tank" ) ))
-- log(serpent.block( get_recipe_results( "iron-plate" ) ))
-- error("get_recipe_results()")


---Returns energy_required as a table for normal and expensive
---@param recipe_name string
---@return table ``{normal, expensive}``
function recipe_get_energy_required(recipe_name)
  local time = {0.5, 0.5}
  if data.raw.recipe[recipe_name] then
    local data_recipe = data.raw.recipe[recipe_name]
    if data_recipe.energy_required then
      time[1] = data_recipe.energy_required or 0.5
      time[2] = data_recipe.energy_required or 0.5
    end
    if data_recipe.normal then
      time[1] = data_recipe.normal.energy_required or 0.5
    end
    if data_recipe.expensive then
      time[2] = data_recipe.expensive.energy_required or 0.5
    end
  end
  return time
end
-- log(serpent.block( get_energy_required( "tank" ) ))
-- log(serpent.block( get_energy_required( "iron-plate" ) ))
-- log(serpent.block( get_energy_required( "iron-gear-wheel" ) ))
-- error("get_energy_required()")


---Returns the input amount of an item. Returns ``nil`` on error
---@param recipe_name string
---@param ingredient_name string
---@return table|nil {normal, expensive}
function recipe_get_amount_in(recipe_name, ingredient_name)
  if data.raw.recipe[recipe_name] then
    local recipe = data.raw.recipe[recipe_name]
    local amount = {0,0}

    if recipe.ingredients then --add next() check?
      for _, value in ipairs(recipe.ingredients) do
        if value.name and value.name == ingredient_name then
          amount = {value.amount or 1, value.amount or 1}
        elseif type(value[1]) == "string" and value[1] == ingredient_name then
          amount = {value[2] or 1, value[2] or 1}
        end
      end
    end
    if recipe.normal and recipe.normal.ingredients then
      for _, value in ipairs(recipe.normal.ingredients) do
        if value.name and value.name == ingredient_name then
          amount[1] = value.amount or 1
        elseif type(value[1]) == "string" and value[1] == ingredient_name then
          amount[1] = value[2] or 1
        end
      end
    end
    if recipe.expensive and recipe.expensive.ingredients then
      for _, value in ipairs(recipe.expensive.ingredients) do
        if value.name and value.name == ingredient_name then
          amount[2] = value.amount or 1
        elseif type(value[1]) == "string" and value[1] == ingredient_name then
          amount[2] = value[2] or 1
        end
      end
    end
    -- amount[1] = amount[1] > 0 and amount[1] or (amount[2] > 0 and amount[2] or 1)
    -- amount[2] = amount[2] > 0 and amount[2] or (amount[1] > 0 and amount[1] or 1)
    return amount
  end
  log("Unknown recipe: "..recipe_name)
  return nil
end
-- log(serpent.block( get_recipe_amount_in( "express-splitter", "advanced-circuit" ) )) --10
-- log(serpent.block( get_recipe_amount_in( "advanced-circuit", "electronic-circuit" ) )) --2
-- log(serpent.block( get_recipe_amount_in( "steel-plate", "iron-plate" ) )) --5, 10
-- error("get_recipe_amount_in()")


---Returns the output amount of an item. Returns ``nil`` on error
---@param recipe_name string
---@param result_name? string can be omitted if recipe and result name are identical
---@return table|nil {normal, expensive}
function recipe_get_amount_out(recipe_name, result_name)
  if data.raw.recipe[recipe_name] then
    result_name = result_name or recipe_name
    local results = recipe_get_results(recipe_name)
    local amount = {0,0}

      if results.results then
        for _, v in ipairs(results.results) do
          if v.name == result_name then
            amount = {v.amount, v.amount}
          end
        end
      end
      if results.normal then
        for _, v in ipairs(results.normal) do
          if v.name == result_name then amount[1] = v.amount end
        end
      end
      if results.expensive then
        for _, v in ipairs(results.expensive) do
          if v.name == result_name then amount[2] = v.amount end
        end
      end
    return amount
  else
    log("Unknown recipe: "..recipe_name)
  end
  return nil
end
-- log(serpent.block( get_recipe_amount_out( "tank" ) ))
-- log(serpent.block( get_recipe_amount_out( "iron-plate" ) ))
-- log(serpent.block( get_recipe_amount_out( "explosives" ) ))
-- log(serpent.block( get_recipe_amount_out( "uranium-processing", "uranium-238" ) ))
-- error("get_recipe_amount_out()")
