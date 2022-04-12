
---Returns the output count of a specified type
---@param recipe_name string
---@param result_type? string
---@param format? boolean removes every key with a value of 0
---@return table ``{results=0, normal=0, expensive=0}``
function ylib.recipe.get_result_count(recipe_name, result_type, format)
  if data.raw.recipe[recipe_name] then
    result_type = result_type or "item"
    format = format or false
    local results = ylib.recipe.get_results(recipe_name)
    local count = {results=0, normal=0, expensive=0}
    for _, value in ipairs(results.results) do
      if not value.type and result_type == "item" then count.results = count.results+1
      elseif value.type and value.type == result_type then count.results = count.results+1
      end
    end
    for _, value in ipairs(results.normal) do
      if not value.type and result_type == "item" then count.normal = count.normal+1
      elseif value.type and value.type == result_type then count.normal = count.normal+1
      end
    end
    for _, value in ipairs(results.expensive) do
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
  else
    warning("Unknown recipe: "..tostring(recipe_name))
  end
end
-- log(serpent.block(recipe.get_result_count("advanced-oil-processing", "fluid", true)))
-- log(serpent.block(recipe.get_result_count("tank", nil, true)))
-- error("recipe.get_amount_out()")


---Sets a recipes ingredient (fluid) temperature
---@param recipe_name string
---@param temperature table contains integers {normal, expensive}
---@param pattern string the string to find within the ingredient name
function ylib.recipe.set_ingredient_temperature(recipe_name, temperature, pattern)
  pattern = pattern or ""
  if data.raw.recipe[recipe_name] then
    for index, value in ipairs(data.raw.recipe[recipe_name].normal.ingredients) do
      if value.type and value.type == "fluid" and string.find(value.name, pattern, 0, true) then
        data.raw.recipe[recipe_name].normal.ingredients[index].temperature = temperature[1]
        data.raw.recipe[recipe_name].expensive.ingredients[index].temperature = temperature[2] -- lets hope theyre the same
      end
    end
  else
    warning("Unknown recipe: "..tostring(recipe_name))
  end
end
-- ylib.recipe.set_ingredient_temperature("molten-iron-plate", {123,456}, "molten-")
-- log(serpent.block(data.raw.recipe["molten-iron-plate"]))
-- error("recipe.set_ingredient_temperature()")


---Sets a recipes results (fluid) temperature
---@param recipe_name string
---@param temperature table contains integers {normal, expensive}
---@param pattern string the string to find within the ingredient name
function ylib.recipe.set_result_temperature(recipe_name, temperature, pattern)
  if data.raw.recipe[recipe_name] then
    for index, value in ipairs(data.raw.recipe[recipe_name].normal.results) do
      if value.type and value.type == "fluid" and string.find(value.name, pattern, 0, true) then
        data.raw.recipe[recipe_name].normal.results[index].temperature = temperature[1]
        data.raw.recipe[recipe_name].expensive.results[index].temperature = temperature[2] -- lets hope theyre the same
      end
    end
  else
    warning("Unknown recipe: "..tostring(recipe_name))
  end
end
-- ylib.recipe.set_result_temperature("molten-iron-ore", {123,456}, "molten-")
-- log(serpent.block(data.raw.recipe["molten-iron-ore"]))
-- error("recipe.set_result_temperature()")

