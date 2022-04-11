
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
  end
  log("Recipe with name "..tostring(recipe_name).." does not exist!")
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
      
    end
    log("Wrong type: "..type(ingredients))
  end
  log("Recipe with name "..tostring(recipe_name).." does not exist!")
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

    end
    log("string expected, got "..type(ingredient_name))
  end
  log("Recipe with name "..tostring(recipe_name).." does not exist!")
end
-- recipe_remove_ingredient("tank", "engine-unit")
-- log(serpent.block(data.raw.recipe["tank"]))
-- recipe_remove_ingredient("gun-turret", "iron-plate")
-- log(serpent.block(data.raw.recipe["gun-turret"]))
-- error("recipe_remove_ingredient()")


--TODO should only replace the ingredient, NOT the amount

---Replaces an ingredient
---@param recipe_name string
---@param ingredient_remove string
---@param ingredient_add string
function recipe_replace_ingredient(recipe_name, ingredient_remove, ingredient_add)
  if data.raw.recipe[recipe_name] then
    local amount = get_recipe_amount_in(recipe_name, ingredient_remove)
    recipe_remove_ingredient(recipe_name, ingredient_remove)
    recipe_add_ingredient(recipe_name, ingredient_add, amount)
  end
  log("Recipe with name "..tostring(recipe_name).." does not exist!")
end


---Adds a result to a recipe
---@param recipe_name string
---@param result string
---@param amount integer
---@param type? string
function recipe_add_result(recipe_name, result, amount, type)
  type = type or get_type(result)
  normal = {type = type, name = result, amount = amount[1]}
  expensive = {type = type, name = result, amount = amount[2]}
  local _r = get_recipe_results(recipe_name)

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