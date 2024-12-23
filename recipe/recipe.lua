
    ------------
    -- GETTER --
    ------------


--TODO format return tables to {x,y}, difficulty replaces content

---Returns a recipes ingredients by difficulty (if available) or nil
---@param recipe_name string
---@return table ``{ingredients={}, normal={}, expensive={}}`` - difficulty keys only if recipe has it
function ylib.recipe.get_ingredients(recipe_name)
  if type(recipe_name) == "string" and data.raw.recipe[recipe_name] then
    local data_recipe = data.raw.recipe[recipe_name]
    local ingredients = {}

    if data_recipe.ingredients then
      ingredients.ingredients = {}
      for i, ingredient in ipairs(data_recipe.ingredients) do
        ingredients.ingredients[i] = ylib.util.add_pairs(ingredient)
      end
    end
    return ingredients
  else
    warning("get_ingredients(): Recipe not found: "..tostring(recipe_name))
  end
  return {}
end
-- log(serpent.block(get_recipe_ingredients("tank")))
-- log(serpent.block(get_recipe_ingredients("steel-furnace")))
-- error("get_recipe_ingredients()")


---Returns a list of all recipes using the given ingredient
---@param item_name string
---@param item_type? string needs to be set if the same name exists for several types
---@return table table List of recipe names
function ylib.recipe.get_byingredient(item_name, item_type)
  -- item_type = item_type or ylib.util.get_item_type(item_name)
  -- if data.raw[item_type][item_name] then
    local recipes = {}

    for recipe_name, data_recipe in pairs(data.raw.recipe) do

      if ylib.util.check_table(data.raw.recipe.ingredients) then
        for _, ingredient in ipairs(data.raw.recipe.ingredients) do
          if ingredient.name and ingredient.name == item_name then table.insert(recipes, recipe_name)
          elseif ingredient[1] and ingredient[1] == item_name then table.insert(recipes, recipe_name)
          end
        end
      end

    end
  return recipes
  -- else
  --   warning(" Item not found: "..tostring(item_name))
  -- end
end
-- log(serpent.block(get_recipes_byingredient("iron-ore")))
-- log(serpent.block(get_recipes_byingredient("uranium-ore")))
-- log(serpent.block(get_recipes_byingredient("copper-plate")))
-- log(serpent.block(get_recipes_byingredient("electric-furnace")))
-- error("get_recipes_byingredient()")


---Returns a table containing the results of the given recipe
---@param recipe_name string
---@return table ``{results={}, normal={}, expensive={}}``
function ylib.recipe.get_results(recipe_name)
    local _return = {results={}, normal={}, expensive={}}

  if data.raw.recipe[recipe_name] then
    local data_recipe = data.raw.recipe[recipe_name]

    if ylib.util.check_table(data_recipe.results) then
      for i, result in pairs(data_recipe.results) do
        _return.results[i] = ylib.util.add_pairs( result )
      end
    elseif data_recipe.result then
      _return.results[1] = ylib.util.add_pairs( {data_recipe.result, data_recipe.result_count} )
    end

  else
    warning(" Recipe not found: "..tostring(recipe_name))
  end
  return _return
end
-- log(serpent.block( ylib.recipe.get_results( "tank" ) ))
-- log(serpent.block( ylib.recipe.get_results( "iron-plate" ) ))
-- error("get_results()")


---Returns all recipes which have the set result --?-//IDEA switch filter for main_product?
---@param result_name string
---@param type? string needs to be set if the same name exists for several types
---@return table ``{results={}, normal={}, expensive={}}``
function ylib.recipe.get_byresult(result_name, type)
  type = type or ylib.util.get_item_type(result_name)
  local recipes = {}

  if data.raw[type][result_name] then

    for recipe_name, recipe_data in pairs(data.raw.recipe) do
      local recipe_results = ylib.recipe.get_results(recipe_name)
      main_product = recipe_data.main_product or result_name

      for _, results in ipairs(recipe_results.results) do
        if results.name
        and results.name == result_name
        and results.name == main_product then table.insert(recipes, recipe_name) end
      end

    end
  else
    warning(tostring(type).."."..tostring(result_name).." not found")
  end
  return recipes
end
-- log(serpent.block(ylib.recipe.get_byresult("uranium-235")))
-- log(serpent.block(ylib.recipe.get_byresult("tank")))
-- log(serpent.block(ylib.recipe.get_byresult("lubricant")))
-- error("ylib.recipe.get_byresult()")


---Returns energy_required as a table for normal and expensive
---@param recipe_name string
---@return table ``{normal, expensive}``
function ylib.recipe.get_energy_required(recipe_name)
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
  else
    warning("Unknown recipe: "..tostring(recipe_name))
  end
  return time
end
-- log(serpent.block( get_energy_required( "tank" ) ))
-- log(serpent.block( get_energy_required( "iron-plate" ) ))
-- log(serpent.block( get_energy_required( "iron-gear-wheel" ) ))
-- error("get_energy_required()")


---Returns the amount of an ingredient. Returns ``{}`` on error
---@param recipe_name string
---@param ingredient_name string
---@return integer
function ylib.recipe.get_ingredient_amount(recipe_name, ingredient_name)
  if data.raw.recipe[recipe_name] then
    local recipe = data.raw.recipe[recipe_name]
    local amount = 0

    if recipe.ingredients then --add next() check?
      for _, value in ipairs(recipe.ingredients) do
        if value.name and value.name == ingredient_name then
          amount = value.amount or 1
        end
      end
    end

    -- amount[1] = amount[1] > 0 and amount[1] or (amount[2] > 0 and amount[2] or 1)
    -- amount[2] = amount[2] > 0 and amount[2] or (amount[1] > 0 and amount[1] or 1)
    return amount
  end
  warning("Unknown recipe: "..recipe_name)
  return 0 --should it return 1 as fallback?
end
-- log(serpent.block( get_recipe_amount_in( "express-splitter", "advanced-circuit" ) )) --10
-- log(serpent.block( get_recipe_amount_in( "advanced-circuit", "electronic-circuit" ) )) --2
-- log(serpent.block( get_recipe_amount_in( "steel-plate", "iron-plate" ) )) --5, 10
-- error("get_recipe_amount_in()")


---Returns the output amount of an item. Returns ``nil`` on error
---@param recipe_name string
---@param result_name? string can be omitted if recipe and result name are identical
---@return table|nil ``{normal, expensive}``
function ylib.recipe.get_amount_out(recipe_name, result_name)
  if data.raw.recipe[recipe_name] then
    result_name = result_name or recipe_name
    local results = ylib.recipe.get_results(recipe_name)
    local amount = {0,0}

      if results.results then
        for _, v in ipairs(results.results) do
          if v.name == result_name then
            amount = {v.amount, v.amount}
          end
        end
      end
    return amount
  else
    warning("Unknown recipe: "..recipe_name)
  end
  return nil
end
-- log(serpent.block( get_recipe_amount_out( "tank" ) ))
-- log(serpent.block( get_recipe_amount_out( "iron-plate" ) ))
-- log(serpent.block( get_recipe_amount_out( "explosives" ) ))
-- log(serpent.block( get_recipe_amount_out( "uranium-processing", "uranium-238" ) ))
-- error("get_recipe_amount_out()")


---Returns the main_product
---@param recipe_name string
---@return table|nil ``{normal, expensive}``
function ylib.recipe.get_main_product(recipe_name)
  if data.raw.recipe[recipe_name] then
    local recipe_data = data.raw.recipe[recipe_name]
    local _r = {}

    if recipe_data.main_product then
      _r = {recipe_data.main_product, recipe_data.main_product}
    end
    return _r
  else
    warning("Unknown recipe: "..recipe_name)
  end
  return nil
end
-- log(serpent.block( get_main_product( "tank" ) ))
-- log(serpent.block( get_main_product( "iron-plate" ) ))
-- log(serpent.block( get_main_product( "explosives" ) ))
-- log(serpent.block( get_main_product( "uranium-processing", "uranium-238" ) ))
-- error("get_main_product()")


----------
-- TEST --
----------


---Returns boolean on ingredient checks or false if the recipe has no ingredient field at all
---@param recipe_name string
---@param ingredient_name string
---@return boolean
function ylib.recipe.has_ingredient(recipe_name, ingredient_name)
  local ingredients = {}
  local _t = ylib.recipe.get_ingredients(recipe_name)
  if ylib.util.check_table(_t) then ingredients = _t end

  local function loop(t)
    for _, value in pairs(t) do
      if value.name == ingredient_name then return true end
    end
    return false
  end

  if ingredients.ingredients then
    return loop(ingredients.ingredients)
  end
  return false
end


---Returns boolean on result checks or nil if the recipe has no result field at all
---@param recipe_name string
---@param result_name string
---@return boolean|nil
function ylib.recipe.has_result(recipe_name, result_name)
  local results = {}
  results = ylib.recipe.get_results(recipe_name)

  local function loop(t)
    for _, value in pairs(t) do
      if value.name == result_name then return true end
    end
    return false
  end

  if results.results then
    return loop(results.results)
  end
  return nil
end


    ------------
    -- SETTER --
    ------------


---Enable or disable a recipe/difficulty
---@param recipe_name string
---@param enabled table ``{normal, expensive}``
function ylib.recipe.set_enabled(recipe_name, enabled)
  if data.raw.recipe[recipe_name] then
    data.raw.recipe[recipe_name].normal.enabled = enabled[1]
    data.raw.recipe[recipe_name].expensive.enabled = enabled[2]
    info(recipe_name.." enabled: ".. tostring(enabled[1]) ..", ".. tostring(enabled[2]))
  else
    warning("Unknown recipe: "..tostring(recipe_name))
  end
end
-- ylib.recipe.set_enabled("tank", {true,false})
-- log(serpent.block(data.raw.recipe["tank"]))
-- error("recipe_set_enabled()")

---Sets a recipes required energy
---@param recipe_name string
---@param energy table ``{normal, expensive}``
function ylib.recipe.set_energy(recipe_name, energy)
  if data.raw.recipe[recipe_name] then
    data.raw.recipe[recipe_name].normal.energy_required = energy[1]
    data.raw.recipe[recipe_name].expensive.energy_required = energy[2]
  else
    warning("Unknown recipe: "..tostring(recipe_name))
  end
end
-- ylib.recipe.set_energy("tank", {1,1})
-- log(serpent.block(data.raw.recipe["tank"]))
-- error("recipe_set_energy()")


---Adds an inredient to a recipe
---@param recipe_name string
---@param ingredient string
---@param amount? integer
function ylib.recipe.add_ingredient(recipe_name, ingredient, amount)
  amount = amount or {1,1}
  if data.raw.recipe[recipe_name] then
    if type(ingredient) == "string" then
      if data.raw.recipe[recipe_name].ingredients then
        table.insert(data.raw.recipe[recipe_name].ingredients, {name = ingredient, amount = amount})
      end
    else
      warning("Wrong type: "..type(ingredient))
    end
  else
    warning("Unknown recipe: "..tostring(recipe_name))
  end
end
-- ylib.recipe.add_ingredient("tank", "TEST", {1,2})
-- log(serpent.block(data.raw.recipe["tank"]))
-- ylib.recipe.add_ingredient("gun-turret", "TEST")
-- log(serpent.block(data.raw.recipe["gun-turret"]))
-- error("recipe_add_ingredient()")


---Adds a result to a recipe
---@param recipe_name string
---@param result string
---@param amount table ``{normal, expensive}``
---@param type? string needs to be set if the same name exists for several types
function ylib.recipe.add_result(recipe_name, result, amount, type)
  type = type or ylib.util.get_item_type(result)
  normal = {type = type, name = result, amount = amount[1]}
  expensive = {type = type, name = result, amount = amount[2]}
  local _r = ylib.recipe.get_results(recipe_name)

  if data.raw.recipe[recipe_name] then
    if data.raw.recipe[recipe_name].result and not data.raw.recipe[recipe_name].results then
      data.raw.recipe[recipe_name].results = {_r, normal}
    end
    if data.raw.recipe[recipe_name].results then
      table.insert(data.raw.recipe[recipe_name].results, normal)
    end
  end
end


---Overwrites the ingredients of the given recipe
---@param recipe_name string
---@param ingredients table ``{ {ingredients}, ... }``
function ylib.recipe.set_ingredients(recipe_name, ingredients)
  if data.raw.recipe[recipe_name] then
    if type(ingredients) == "table" then
      if data.raw.recipe[recipe_name].ingredients then
        data.raw.recipe[recipe_name].ingredients = ingredients
      end
    else
      warning("Wrong type: "..type(ingredients))
    end
  else
    warning("Unknown recipe: "..tostring(recipe_name))
  end
end


---Removes an ingredient from the recipe
---@param recipe_name string
---@param ingredient_name string
function ylib.recipe.remove_ingredient(recipe_name, ingredient_name)
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

    else
      warning("string expected, got "..type(ingredient_name))
    end
  else
    warning("Unknown recipe: "..tostring(recipe_name))
  end
end


---Removes an result from the recipe
---@param recipe_name string
---@param result_name string
function ylib.recipe.remove_result(recipe_name, result_name)
  if data.raw.recipe[recipe_name] then
    if type(result_name) == "string" then

      local function remove(_t)
        for i, value in ipairs(_t) do
          if (value.name or value[1]) == result_name then
            table.remove(_t, i)
          end
        end
      end

      if data.raw.recipe[recipe_name].result then
        data.raw.recipe[recipe_name].result = nil
        data.raw.recipe[recipe_name].result_count = nil
      end
      if data.raw.recipe[recipe_name].results then
        remove(data.raw.recipe[recipe_name].results)
      end

    else
      warning("string expected, got "..type(result_name))
    end
  else
    warning("Unknown recipe: "..tostring(recipe_name))
  end
end


---Replaces an ingredient
---@param recipe_name string
---@param ingredient_remove string
---@param ingredient_add string
---@param amount? integer
function ylib.recipe.replace_ingredient(recipe_name, ingredient_remove, ingredient_add, amount)
  if data.raw.recipe[recipe_name] then
    amount = amount or ylib.recipe.get_ingredient_amount(recipe_name, ingredient_remove)
    if amount == 0 then warning(recipe_name.." - "..ingredient_add.." couldn't find amount, defaulting to 1"); amount = 1 end
    ylib.recipe.remove_ingredient(recipe_name, ingredient_remove)
    ylib.recipe.add_ingredient(recipe_name, ingredient_add, amount)
    info("Replaced "..ingredient_remove.." with "..ingredient_add.." in "..recipe_name)
  else
    warning("Unknown recipe: "..tostring(recipe_name))
  end
end


---Replaces an ingredient
---@param recipe_name string
---@param ingredient_remove string
---@param ingredient_add string
function ylib.recipe.replace_ingredient_name(recipe_name, ingredient_remove, ingredient_add)
  local data_recipe = data.raw.recipe[recipe_name]
  if data_recipe then
    local data_ingredients = ylib.recipe.get_results(recipe_name)

    local function replace(key)
      for i, result in ipairs(data_ingredients[key]) do
        if result.name == ingredient_remove then
          data_ingredients[key][i].name = ingredient_add
          data.raw.recipe[recipe_name][key].ingredients = data_ingredients[key]
          info("Replaced "..ingredient_remove.." with "..ingredient_add.." in "..recipe_name)
        end
      end
    end

    if data_ingredients.ingredients then
      for i, result in ipairs(data_ingredients.ingredients) do
        if result.name == ingredient_remove then
          data_ingredients.ingredients[i].name = ingredient_add
          data.raw.recipe[recipe_name].ingredients = data_ingredients.ingredients
          info("Replaced "..ingredient_remove.." with "..ingredient_add.." in "..recipe_name)
        end
      end
    end
    if data_ingredients.normal then replace("normal") end
    if data_ingredients.expensive then replace("expensive") end
  else
    warning("Unknown recipe: "..tostring(recipe_name))
  end
end

---Replaces a result
---@param recipe_name string
---@param result_remove string
---@param result_add string
---@param amount? integer
function ylib.recipe.replace_result(recipe_name, result_remove, result_add, amount)
  if data.raw.recipe[recipe_name] then
    amount = amount or ylib.recipe.get_amount_in(recipe_name, result_remove)
    ylib.recipe.remove_result(recipe_name, result_remove)
    ylib.recipe.add_result(recipe_name, result_add, amount)
    info("Replaced "..result_remove.." with "..result_add.." in "..recipe_name)
  else
    warning("Unknown recipe: "..tostring(recipe_name))
  end
end


---Replaces a result
---@param recipe_name string
---@param result_remove string
---@param result_add string
function ylib.recipe.replace_result_name(recipe_name, result_remove, result_add)
  local data_recipe = data.raw.recipe[recipe_name]
  if data_recipe then
    local data_results = ylib.recipe.get_results(recipe_name)

    local function replace(key)
      for i, result in ipairs(data_results[key]) do
        if result.name == result_remove then
          data_results[key][i].name = result_add
          data.raw.recipe[recipe_name][key].results = data_results[key]
          info("Replaced "..result_remove.." with "..result_add.." in "..recipe_name)
        end
      end
    end

    if data_results.results then
      for i, result in ipairs(data_results.results) do
        if result.name == result_remove then
          data_results.results[i].name = result_add
          data.raw.recipe[recipe_name].results = data_results.results
          info("Replaced "..result_remove.." with "..result_add.." in "..recipe_name)
        end
      end
    end
    if data_results.normal then replace("normal") end
    if data_results.expensive then replace("expensive") end

  else
    warning("Unknown recipe: "..tostring(recipe_name))
  end
end


---Sets the main_product
---@param recipe_name string
---@param main_product string
function ylib.recipe.set_main_product(recipe_name, main_product)
  local data_recipe = data.raw.recipe[recipe_name]
  if data_recipe then

    if data_recipe.main_product then data.raw.recipe[recipe_name].main_product = main_product end
    if data_recipe.normal then data.raw.recipe[recipe_name].normal.main_product = main_product end
    if data_recipe.expensive then data.raw.recipe[recipe_name].expensive.main_product = main_product end

  else
    warning("Unknown recipe: "..tostring(recipe_name))
  end
end
