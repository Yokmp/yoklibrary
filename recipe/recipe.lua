
    ------------
    -- SETTER --
    ------------

---Enable or disable a recipe/difficulty
---@param recipe_name string
---@param enabled table contains boolean {normal, expensive}
function ylib.recipe.set_enabled(recipe_name, enabled)
  if data.raw.recipe[recipe_name] then
    data.raw.recipe[recipe_name].normal.enabled = enabled[1]
    data.raw.recipe[recipe_name].expensive.enabled = enabled[2]
    if loglevel then log(recipe_name.." enabled: ".. tostring(enabled[1]) ..", ".. tostring(enabled[2])) end
  else
    log("Unknown recipe: "..tostring(recipe_name))
  end
end
-- ylib.recipe.set_enabled("tank", {true,false})
-- log(serpent.block(data.raw.recipe["tank"]))
-- error("recipe_set_enabled()")

---Sets a recipes required energy
---@param recipe_name string
---@param energy table contains float {normal, expensive}
function ylib.recipe.set_energy(recipe_name, energy)
  if data.raw.recipe[recipe_name] then
    data.raw.recipe[recipe_name].normal.energy_required = energy[1]
    data.raw.recipe[recipe_name].expensive.energy_required = energy[2]
  else
    log("Unknown recipe: "..tostring(recipe_name))
  end
end
-- ylib.recipe.set_energy("tank", {1,1})
-- log(serpent.block(data.raw.recipe["tank"]))
-- error("recipe_set_energy()")


---Adds an inredient to a recipe
---@param recipe_name string
---@param ingredient string
---@param amount? table ``{nomral, expensive}``
function ylib.recipe.add_ingredient(recipe_name, ingredient, amount)
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
-- ylib.recipe.add_ingredient("tank", "TEST", {1,2})
-- log(serpent.block(data.raw.recipe["tank"]))
-- ylib.recipe.add_ingredient("gun-turret", "TEST")
-- log(serpent.block(data.raw.recipe["gun-turret"]))
-- error("recipe_add_ingredient()")


---Adds a result to a recipe
---@param recipe_name string
---@param result string
---@param amount integer
---@param type? string needs to be set if the same name exists for several types
function ylib.recipe.add_result(recipe_name, result, amount, type)
  type = type or get_type(result)
  normal = {type = type, name = result, amount = amount[1]}
  expensive = {type = type, name = result, amount = amount[2]}
  local _r = ylib.recipe.get.results(recipe_name)

  if data.raw.recipe[recipe_name] then
    if data.raw.recipe[recipe_name].result and not data.raw.recipe[recipe_name].results then
      data.raw.recipe[recipe_name].results = {_r, normal}
    end
    if data.raw.recipe[recipe_name].results then
      table.insert(data.raw.recipe[recipe_name].results, normal)
    end

    if data.raw.recipe[recipe_name].normal then
      if data.raw.recipe[recipe_name].normal.result and not data.raw.recipe[recipe_name].normal.results then
        data.raw.recipe[recipe_name].normal.results = {_r, normal}
      end
      if data.raw.recipe[recipe_name].normal.results then
        table.insert(data.raw.recipe[recipe_name].results, normal)
      end
    end

    if data.raw.recipe[recipe_name].expensive then
      if data.raw.recipe[recipe_name].expensive.result and not data.raw.recipe[recipe_name].expensive.results then
        data.raw.recipe[recipe_name].expensive.results = {_r, expensive}
      end
      if data.raw.recipe[recipe_name].expensive.results then
        table.insert(data.raw.recipe[recipe_name].results, expensive)
      end
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
-- ylib.recipe.remove_ingredient("tank", "engine-unit")
-- log(serpent.block(data.raw.recipe["tank"]))
-- ylib.recipe.remove_ingredient("gun-turret", "iron-plate")
-- log(serpent.block(data.raw.recipe["gun-turret"]))
-- ylib.recipe.remove_ingredient("production-science-pack", "rail")
-- log(serpent.block(data.raw.recipe["production-science-pack"]))
-- error("recipe_remove_ingredient()")


--TODO should only replace the ingredient, NOT the amount

---Replaces an ingredient
---@param recipe_name string
---@param ingredient_remove string
---@param ingredient_add string
function ylib.recipe.replace_ingredient(recipe_name, ingredient_remove, ingredient_add)
  if data.raw.recipe[recipe_name] then
    local amount = ylib.recipe.get_amount_in(recipe_name, ingredient_remove)
    ylib.recipe.remove_ingredient(recipe_name, ingredient_remove)
    ylib.recipe.add_ingredient(recipe_name, ingredient_add, amount)
    info("Replaced "..ingredient_remove.." with "..ingredient_add.." in "..recipe_name)
  else
    log("Recipe "..tostring(recipe_name).." does not exist!")
  end
end


    ------------
    -- GETTER --
    ------------


--TODO format return tables to {x,y}, difficulty replaces content

---Returns a recipes ingredients by difficulty (if available) or nil
---@param recipe_name string
---@return table|nil ``{ingredients={}, normal={}, expensive={}}``
function ylib.recipe.get_ingredients(recipe_name)
  if type(recipe_name) == "string" and data.raw.recipe[recipe_name] then
    local data_recipe = data.raw.recipe[recipe_name]
    local ingredients = {}

    if data.raw.recipe.ingredients and data.raw.recipe.ingredients then
      ingredients.ingredients = {}
      for i, ingredient in ipairs(data.raw.recipe.ingredients) do
        ingredients.ingredients[i] = util.add_pairs(ingredient)
      end
    end
    if data.raw.recipe.normal and data.raw.recipe.normal.ingredients then
      ingredients.normal = {}
      for i, ingredient in ipairs(data.raw.recipe.normal.ingredients) do
        ingredients.normal[i] = util.add_pairs(ingredient)
      end
    end
    if data.raw.recipe.expensive and data.raw.recipe.expensive.ingredients then
      ingredients.expensive = {}
      for i, ingredient in ipairs(data.raw.recipe.expensive.ingredients) do
        ingredients.expensive[i] = util.add_pairs(ingredient)
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
---@param item_type? string needs to be set if the same name exists for several types
---@return table table List of recipe names
function ylib.recipe.get_byingredient(item_name, item_type)
  item_type = item_type or get_type(item_name)
  if data.raw[item_type][item_name] then
    local recipes = {}

    for recipe_name, data_recipe in pairs(data.raw.recipe) do
      if util.check_table(data.raw.recipe.ingredients) then
        for _, ingredient in ipairs(data.raw.recipe.ingredients) do
          if ingredient.name and ingredient.name == item_name then table.insert(recipes, recipe_name)
          elseif ingredient[1] and ingredient[1] == item_name then table.insert(recipes, recipe_name)
          end
        end
      end

      if data.raw.recipe.normal then
        if util.check_table(data.raw.recipe.normal.ingredients) then
          for _, ingredient in ipairs(data.raw.recipe.normal.ingredients) do
            if ingredient.name == item_name then table.insert(recipes, recipe_name) end
          end
        end
      end

      if data.raw.recipe.expensive then
        if util.check_table(data.raw.recipe.expensive.ingredients) then
          for _, ingredient in ipairs(data.raw.recipe.expensive.ingredients) do
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
---@return table ``{results={}, normal={}, expensive={}}``
function ylib.recipe.get_results(recipe_name)
    local _return = {results={}, normal={}, expensive={}}

  if data.raw.recipe[recipe_name] then
    local data_recipe = data.raw.recipe[recipe_name]

    if util.check_table(data.raw.recipe.results) then
      for i, result in pairs(data.raw.recipe.results) do
        _return.results[i] = util.add_pairs( result )
      end
    elseif data.raw.recipe.result then
      _return.results[1] = util.add_pairs( {data.raw.recipe.result, data.raw.recipe.result_count} )
    end

    if data.raw.recipe.normal then
      if util.check_table(data.raw.recipe.normal.results) then
        for i, result in pairs(data.raw.recipe.normal.results) do
          _return.normal[i] = util.add_pairs( result )
        end
      elseif data.raw.recipe.normal.result then
        _return.normal[1] = util.add_pairs( {data.raw.recipe.normal.result, data.raw.recipe.normal.result_count} )
      end
    end

    if data.raw.recipe.expensive then
      if util.check_table(data.raw.recipe.expensive.results) then
        for i, result in pairs(data.raw.recipe.expensive.results) do
          _return.expensive[i] = util.add_pairs( result )
        end
      elseif data.raw.recipe.expensive.result then
        _return.expensive[1] = util.add_pairs( {data.raw.recipe.expensive.result, data.raw.recipe.expensive.result_count} )
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


---Returns all recipes which have the set result
---@param result_name string
---@param type? string needs to be set if the same name exists for several types
---@return table ``{results={}, normal={}, expensive={}}``
function ylib.recipe.get_byresult(result_name, type)
  type = type or get_type(result_name)
  local recipes = {}

  if data.raw[type][result_name] then

    for recipe_name, _ in pairs(data.raw.recipe) do
      local recipe_results = ylib.recipe.get_results(recipe_name)

      for _, results in ipairs(recipe_results.results) do
        if results.name and results.name == result_name then table.insert(recipes, recipe_name) end
      end

      for _, results in ipairs(recipe_results.normal) do
        if results.name and results.name == result_name then table.insert(recipes, recipe_name) end
      end

      for _, results in ipairs(recipe_results.expensive) do
        if results.name and results.name == result_name and not recipes.name == result_name then table.insert(recipes, recipe_name) end
      end

    end
  else
    log(tostring(type).."."..tostring(result_name).." not found")
  end
  return recipes
end
-- log(serpent.block(ylib.recipe.get_byresults("uranium-235")))
-- log(serpent.block(ylib.recipe.get_byresults("tank")))
-- log(serpent.block(ylib.recipe.get_byresults("lubricant")))
-- error("ylib.recipe.get_byresults()")


---Returns energy_required as a table for normal and expensive
---@param recipe_name string
---@return table ``{normal, expensive}``
function ylib.recipe.get_energy_required(recipe_name)
  local time = {0.5, 0.5}
  if data.raw.recipe[recipe_name] then
    local data_recipe = data.raw.recipe[recipe_name]
    if data.raw.recipe.energy_required then
      time[1] = data.raw.recipe.energy_required or 0.5
      time[2] = data.raw.recipe.energy_required or 0.5
    end
    if data.raw.recipe.normal then
      time[1] = data.raw.recipe.normal.energy_required or 0.5
    end
    if data.raw.recipe.expensive then
      time[2] = data.raw.recipe.expensive.energy_required or 0.5
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
function ylib.recipe.get_amount_in(recipe_name, ingredient_name)
  if data.raw.recipe[recipe_name] then
    local recipe = data.raw.recipe[recipe_name]
    local amount = {0,0}

    if ylib.recipe.ingredients then --add next() check?
      for _, value in ipairs(ylib.recipe.ingredients) do
        if value.name and value.name == ingredient_name then
          amount = {value.amount or 1, value.amount or 1}
        elseif type(value[1]) == "string" and value[1] == ingredient_name then
          amount = {value[2] or 1, value[2] or 1}
        end
      end
    end
    if ylib.recipe.normal and ylib.recipe.normal.ingredients then
      for _, value in ipairs(ylib.recipe.normal.ingredients) do
        if value.name and value.name == ingredient_name then
          amount[1] = value.amount or 1
        elseif type(value[1]) == "string" and value[1] == ingredient_name then
          amount[1] = value[2] or 1
        end
      end
    end
    if ylib.recipe.expensive and ylib.recipe.expensive.ingredients then
      for _, value in ipairs(ylib.recipe.expensive.ingredients) do
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

