
--//TODO

-------------
-- EFFECTS --
-------------

---Adds an effect to a technology
---@param technology_name string
---@param recipe_name string
function ylib.technology.add_effect(technology_name, recipe_name)
  if data.raw.technology[technology_name] and data.raw.technology[technology_name].effects then
    table.insert(data.raw.technology[technology_name].effects, { type = "unlock-recipe", recipe = recipe_name })
    if loglevel then log("added "..recipe_name.." to ".. technology_name) end
  else
    warning("Unknown technology or missing key: "..tostring(technology_name))
  end
end

---Removed an effects from a technology
---@param technology_name string
---@param recipe_name string
function ylib.technology.remove_effect(technology_name, recipe_name)
  if data.raw.technology[technology_name] and data.raw.technology[technology_name].effects then
    for index, value in ipairs(data.raw.technology[technology_name].effects) do
      if value.recipe == recipe_name then
        table.remove(data.raw.technology[technology_name].effects, index)
        if loglevel then log("removed "..recipe_name.." from ".. technology_name) end
      end
    end
  else
    warning("Unknown technology or missing key: "..tostring(technology_name))
  end
end

-----------------
-- INGREDIENTS --
-----------------

---Adds or replaces an ingredient by another
---@param technology_name string
---@param ingredient_name string
---@param amount number
function ylib.technology.set_ingredient(technology_name, ingredient_name, amount)
  ylib.technology.remove_ingredient(technology_name, ingredient_name)
  if data.raw.technology[technology_name] then
    table.insert(data.raw.technology[technology_name].unit.ingredients, {ingredient_name, amount})
  else
    warning("Unknown technology or missing key: "..tostring(technology_name))
  end
end

---Removes an ingredient
---@param technology_name string
---@param ingredient string
function ylib.technology.remove_ingredient(technology_name, ingredient)
  if data.raw.technology[technology_name] then
    for index, value in ipairs(data.raw.technology[technology_name].unit.ingredients) do
      if value[1] == ingredient then
        table.remove(data.raw.technology[technology_name].unit.ingredients, index)
      end
    end
  -- else
  --   warning("Unknown technology or missing key: "..tostring(technology_name))
  end
end

------------
-- HELPER --
------------

---Returns which technologies enable a recipe.
---@param recipe_name string
---@return table
function ylib.technology.get_techs_enable_recipe(recipe_name)
  local _techs = {}
  for _, value in pairs(data.raw.technology) do
    if value.effects then
      for _, effect in ipairs(value.effects) do
        if effect.recipe and effect.recipe == recipe_name then
          _techs[#_techs+1] = value.name
        end
      end
    end
  end
  if not _techs then
    warning("Unknown technology: "..tostring(recipe_name))
  end
  return _techs
end


---Returns the prerequisites of a technology
---@param tech_name string
---@return table
function ylib.technology.get_prerequisites(tech_name)
  if data.raw.technology[tech_name] then
    return util.table.deepcopy(data.raw.technology[tech_name].prerequisites)
  else
    info("Technology "..tech_name.." has no prerequisites!")
  end
  return {}
end


---Adds prerequisites to a technology
---@param tech_name string
function ylib.technology.add_prerequisites(tech_name, prerequisites)
  if data.raw.technology[tech_name] then
    if ylib.util.check_table(prerequisites) then
      local _t1 = ylib.technology.get_prerequisites(tech_name)
      data.raw.technology[tech_name].prerequisites = ylib.util.table_merge(_t1, prerequisites)
    else
      warning("Prerequisites for "..tech_name.." is not a table!")
    end
  else
    info("Technology "..tech_name.." has no prerequisites!")
  end
end


---Sets the parent of a technology which inherits all prerequisites and ingredients of the parent
---@param tech_name string
---@param parent_name string
---@param parent_as_prerequisite? boolean use the parents prerquisites (false) or the parent as prerquisite(true)
function ylib.technology.set_parent(tech_name, parent_name, parent_as_prerequisite)
  parent_as_prerequisite = parent_as_prerequisite or true
  local p_pre = ylib.technology.get_prerequisites(parent_name)

  if data.raw.technology[tech_name] and data.raw.technology[parent_name] then
    if parent_as_prerequisite then table.insert(p_pre, parent_name) end
    data.raw.technology[tech_name].prerequisites = p_pre
    data.raw.technology[tech_name].unit.ingredients = util.table.deepcopy(data.raw.technology[parent_name].unit.ingredients)
  else
    warning(tostring(tech_name).." or "..tostring(parent_name).." do not exist!")
  end
end


--//TODO testing
-- ---Returns icons for technology
-- ---@param tech_name string icon name for technology
-- ---@param item_name string used when tech has no icon
-- ---@param shift? table
-- ---@return table
-- function ylib.technology.icon_compose(tech_name, item_name, shift)

--   if ylib.icon.icons["Molten_Metals"][tech_name] then
--     return {ylib.icon.icons:get("Molten_Metals", tech_name)}
--   end
--   local icon = ylib.icon.get_item_icon(item_name)
--   local drop = ylib.icon.icons:get("Molten_Metals", "molten-drop-tech")
--   log(serpent.block(icon))

--   icon.scale = 1
--   icon.shift = shift or {0,5}
--   drop.scale = icon.icon_size/drop.icon_size
--   return { icon, drop }
-- end
-- log(serpent.block(ylib.technology.icon_compose("aluminum-6061")))