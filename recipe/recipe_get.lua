
--TODO format return tables to {x,y}, difficulty replaces content

---Returns a recipes ingredients by difficulty (if available) or nil
---@param recipe_name string
---@return table|nil ``{ingredients={}, normal={}, expensive={}}``
function get_recipe_ingredients(recipe_name)
  local _return = {ingredients={}, normal={}, expensive={}}

  if data.raw.recipe[recipe_name] then
    local data_recipe = data.raw.recipe[recipe_name]

    if data_recipe.ingredients and data_recipe.ingredients then
      _return.ingredients = {}
      for i, ingredient in ipairs(data_recipe.ingredients) do
        _return.ingredients[i] = add_pairs(ingredient)
      end
    end
    if data_recipe.normal and data_recipe.normal.ingredients then
      _return.normal = {}
      for i, ingredient in ipairs(data_recipe.normal.ingredients) do
        _return.normal[i] = add_pairs(ingredient)
      end
    end
    if data_recipe.expensive and data_recipe.expensive.ingredients then
      _return.expensive = {}
      for i, ingredient in ipairs(data_recipe.expensive.ingredients) do
        _return.expensive[i] = add_pairs(ingredient)
      end
    end
    return _return
  else
    log(" Recipe not found: "..tostring(recipe_name))
  end
  return nil
end
-- log(serpent.block(get_recipe_ingredients("tank")))
-- log(serpent.block(get_recipe_ingredients("steel-furnace")))
-- error("get_recipe_ingredients()")


---Returns a list of all recipes using the given ingredient
---@param type string eg. item
---@param name string
---@return table recipes List of recipe names
function get_recipes_byingredient(name, type)
  type = type or get_type(name)
  if data.raw[type][name] then
    local recipes = {}

    for recipe_name, data_recipe in pairs(data.raw.recipe) do
      if check_table(data_recipe.ingredients) then
        for _, ingredient in ipairs(data_recipe.ingredients) do
          if ingredient.name and ingredient.name == name then table.insert(recipes, recipe_name)
          elseif ingredient[1] and ingredient[1] == name then table.insert(recipes, recipe_name)
          end
        end
      end

      if data_recipe.normal then
        if check_table(data_recipe.normal.ingredients) then
          for _, ingredient in ipairs(data_recipe.normal.ingredients) do
            if ingredient.name == name then table.insert(recipes, recipe_name) end
          end
        end
      end

      if data_recipe.expensive then
        if check_table(data_recipe.expensive.ingredients) then
          for _, ingredient in ipairs(data_recipe.expensive.ingredients) do
            if ingredient.name == name then table.insert(recipes, recipe_name) end
          end
        end
      end
    end
  return recipes
  else
    log(tostring(type).." not found: "..tostring(name))
  end
end
-- log(serpent.block(get_recipes_byingredient("iron-ore")))
-- log(serpent.block(get_recipes_byingredient("uranium-ore")))
-- log(serpent.block(get_recipes_byingredient("copper-plate")))
-- log(serpent.block(get_recipes_byingredient("lubricant")))
-- error("get_recipes_byingredient()")


---Returns a table containing the results of the given recipe
---@param recipe_name string
---@return table ``{results={}, normal={}, expensive={}}``
function get_recipe_results(recipe_name)
  local _return = {results={}, normal={}, expensive={}}

  if data.raw.recipe[recipe_name] then
    local data_recipe = data.raw.recipe[recipe_name]

    if check_table(data_recipe.results) then
      for i, result in pairs(data_recipe.results) do
        _return.results[i] = add_pairs( result )
      end
    elseif data_recipe.result then
      _return.results[1] = add_pairs( {data_recipe.result, data_recipe.result_count} )
    end

    if data_recipe.normal then
      if check_table(data_recipe.normal.results) then
        for i, result in pairs(data_recipe.normal.results) do
          _return.normal[i] = add_pairs( result )
        end
      elseif data_recipe.normal.result then
        _return.normal[1] = add_pairs( {data_recipe.normal.result, data_recipe.normal.result_count} )
      end
    end

    if data_recipe.expensive then
      if check_table(data_recipe.expensive.results) then
        for i, result in pairs(data_recipe.expensive.results) do
          _return.expensive[i] = add_pairs( result )
        end
      elseif data_recipe.expensive.result then
        _return.expensive[1] = add_pairs( {data_recipe.expensive.result, data_recipe.expensive.result_count} )
      end
    end

  else
    log("Recipe not found: "..tostring(recipe_name))
  end
  return _return
end
-- log(serpent.block( get_recipe_results( "tank" ) ))
-- log(serpent.block( get_recipe_results( "iron-plate" ) ))
-- log(serpent.block( get_recipe_results( "advanced-oil-processing" ) ))
-- error("get_recipe_results()")


---Returns all recipes which have the set result
---@param name string
---@param type string
---@return table ``{results={}, normal={}, expensive={}}``
function get_recipes_byresults(name, type)
  type = type or get_type(name)
  local recipes = {}

  if data.raw[type][name] then

    for recipe_name, _ in pairs(data.raw.recipe) do
      local recipe_results = get_recipe_results(recipe_name)

      for _, results in ipairs(recipe_results.results) do
        if results.name and results.name == name then table.insert(recipes, recipe_name) end
      end

      for _, results in ipairs(recipe_results.normal) do
        if results.name and results.name == name then table.insert(recipes, recipe_name) end
      end

      for _, results in ipairs(recipe_results.expensive) do
        if results.name and results.name == name and not recipes.name == name then table.insert(recipes, recipe_name) end
      end

    end
  else
    log(tostring(type).."."..tostring(name).." not found")
  end
  return recipes
end
-- log(serpent.block(get_recipes_byresults("uranium-235")))
-- log(serpent.block(get_recipes_byresults("tank")))
-- log(serpent.block(get_recipes_byresults("lubricant")))
-- error("get_recipes_byresults()")


---Returns energy_required as a table for normal and expensive
---@param recipe_name string
---@return table ``{normal, expensive}``
function get_energy_required(recipe_name)
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
function get_recipe_amount_in(recipe_name, ingredient_name)
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
  log("amount_in - Unknown recipe: "..recipe_name)
  return nil
end
-- log(serpent.block( get_recipe_amount_in( "express-splitter", "advanced-circuit" ) )) --10
-- log(serpent.block( get_recipe_amount_in( "advanced-circuit", "electronic-circuit" ) )) --2
-- log(serpent.block( get_recipe_amount_in( "steel-plate", "iron-plate" ) )) --5, 10
-- error("get_recipe_amount_in()")


---Returns the output amount of an item. Returns ``nil`` on error
---@param recipe_name string
---@param item_name? string can be omitted if recipe and result name are identical
---@return table|nil {normal, expensive}
function get_recipe_amount_out(recipe_name, item_name)
  if data.raw.recipe[recipe_name] then
    item_name = item_name or recipe_name
    local results = get_recipe_results(recipe_name)
    local amount = {0,0}

      if results.results then
        for _, v in ipairs(results.results) do
          if v.name == item_name then
            amount = {v.amount, v.amount}
          end
        end
      end
      if results.normal then
        for _, v in ipairs(results.normal) do
          if v.name == item_name then amount[1] = v.amount end
        end
      end
      if results.expensive then
        for _, v in ipairs(results.expensive) do
          if v.name == item_name then amount[2] = v.amount end
        end
      end
    return amount
  end
  log("amount_out - Unknown recipe: "..recipe_name)
  return nil
end
-- log(serpent.block( get_recipe_amount_out( "tank" ) )) --1,1
-- log(serpent.block( get_recipe_amount_out( "iron-plate" ) )) --1,1
-- log(serpent.block( get_recipe_amount_out( "explosives" ) )) --2,2
-- error("get_recipe_amount_out()")


---Returns the output count of a specified type
---@param recipe_name string
---@param result_type? string
---@param format? boolean removes every key with a value of 0
---@return table ``{results=0, normal=0, expensive=0}``
function get_recipe_result_count(recipe_name, result_type, format)
  if data.raw.recipe[recipe_name] then
    result_type = result_type or "item"
    format = format or false
    local results = get_recipe_results(recipe_name)
    local count = {results=0, normal=0, expensive=0}
    for index, value in ipairs(results.results) do
      if not value.type and result_type == "item" then count.results = count.results+1
      elseif value.type and value.type == result_type then count.results = count.results+1
      end
    end
    for index, value in ipairs(results.normal) do
      if not value.type and result_type == "item" then count.normal = count.normal+1
      elseif value.type and value.type == result_type then count.normal = count.normal+1
      end
    end
    for index, value in ipairs(results.expensive) do
      if not value.type and result_type == "item" then count.expensive = count.expensive+1
      elseif value.type and value.type == result_type then count.expensive = count.expensive+1
      end
    end
    if format then
      local _t = {}
      if (count.normal + count.expensive ) > 0 then count.results = nil end
      for key, value in pairs(count) do
        if value > 0 then _t[key] = value end
      end
      count = _t
    end
    return count
  end
end
-- log(serpent.block(get_recipe_result_count("advanced-oil-processing", "fluid", true)))
-- log(serpent.block(get_recipe_result_count("tank", nil, true)))
-- error("get_recipe_amount_out()")