
----------------
-- TECHNOLOGY --
----------------

---Creates a new technology
---@param tech_name string
---@param icon_name string
---@param prerequisites table use technology_set_parent()
---@param ingredient table or use technology_add_ingedient()
---@param localized_name? string item-name
---@param count? number
---@param time? number
function new_technology_ext(tech_name, icon_name, prerequisites, ingredient, localized_name, count, time)

  data:extend({
    {
      type = "technology",
      name = tech_name,
      localised_name = {"", {"item-name."..localized_name}, " ", {"item-name.casting"}},
      icons = technology_icon_compose(icon_name),
      effects = {},
      prerequisites = prerequisites,
      unit =
      {
        count = count or 75,
        ingredients = {ingredient},
        time = time or 5
      },
      order = "c["..tech_name.."]"
    },
  })
end

---Wrapper for new_technology_ext(), also sets the parent technology
---@param tech_name string
---@param icon_name string
---@param parent_name string
---@param localized_name? string omittable if icon and locale names match
function new_technology(tech_name, icon_name, parent_name, localized_name)
  new_technology_ext(tech_name, icon_name, {}, {}, localized_name or icon_name)
  technology_set_parent(tech_name, parent_name)
end


---Adds a recipe as effect to a technology
---@param technology_name string
---@param recipe_name string
function technology_add_effect(technology_name, recipe_name)
  if data.raw.technology[technology_name] and data.raw.technology[technology_name].effects then
    table.insert(data.raw.technology[technology_name].effects, { type = "unlock-recipe", recipe = recipe_name })
    if logging then log("added "..recipe_name.." to ".. technology_name) end
  else
    log("Unknown technology or missing key: "..tostring(technology_name))
  end
end

---Removed a recipe from a technology
---@param technology_name string
---@param recipe_name string
function technology_remove_effect(technology_name, recipe_name)
  if data.raw.technology[technology_name] and data.raw.technology[technology_name].effects then
    for index, value in ipairs(data.raw.technology[technology_name].effects) do
      if value.recipe == recipe_name then
        table.remove(data.raw.technology[technology_name].effects, index)
        if logging then log("removed "..recipe_name.." from ".. technology_name) end
      end
    end
  else
    log("Unknown technology or missing key: "..tostring(technology_name))
  end
end

---Add an ingredient to a technology
---@param technology_name string
---@param ingredient table
---@param amount number
function technology_add_ingredient(technology_name, ingredient, amount)
  if data.raw.technology[technology_name] then
    table.insert(data.raw.technology[technology_name].unit.ingredients, {ingredient, amount})
  end
end

---Removes an ingredient
---@param technology_name string
---@param ingredient string
function technology_remove_ingredient(technology_name, ingredient)
  if data.raw.technology[technology_name] then
    for index, value in ipairs(data.raw.technology[technology_name].unit.ingredients) do
      if value[1] == ingredient then
        table.remove(data.raw.technology[technology_name].unit.ingredients, index)
      end
    end
  end
end

---Replaces an ingredient by another
---@param technology_name string
---@param ingredient_old string
---@param ingredient_new string
---@param amount number
function technology_replace_ingredient(technology_name, ingredient_old, ingredient_new, amount)
  technology_remove_ingredient(technology_name, ingredient_old)
  technology_add_ingredient(technology_name, ingredient_new, amount)
end

---Returns which technologies enable a recipe.
---@param recipe_name string
---@return table technologies
function get_techs_enable_recipe(recipe_name)
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
  return _techs
end

---Returns the prerequisites of a technology
---@param tech_name string
---@return table
function technology_get_prerequisites(tech_name)
  if data.raw.technology[tech_name] then
    return util.table.deepcopy(data.raw.technology[tech_name].prerequisites)
  end
  if logging then log("Technology "..tech_name.." has no prerequisites!") end
  return {}
end

---Sets the parent of a technology which inherits all prerequisites and ingredients of the parent
---@param tech_name string
---@param parent_name string
---@param use_prerequisites boolean
function technology_set_parent(tech_name, parent_name, use_prerequisites)
  use_prerequisites = use_prerequisites or true
  local prereq = technology_get_prerequisites(parent_name)

  if data.raw.technology[tech_name] and data.raw.technology[parent_name] then
    if use_prerequisites then table.insert(prereq, parent_name) end
    data.raw.technology[tech_name].prerequisites = prereq
    data.raw.technology[tech_name].unit.ingredients = util.table.deepcopy(data.raw.technology[parent_name].unit.ingredients)
  end

end


---Returns icons for technology
---@param icon_name string must be a valid item name
---@param size? number
---@param scale? number multiplier
---@param shift? table
---@return table
function technology_icon_compose(icon_name, size, scale, shift)
  local icon = get_icon_from_item(icon_name)
  size = size or 128
  scale = scale or (icon.icon_size/size)
  return {
    {
      icon = icon.icon,
      icon_size = icon.icon_size,
      icon_mipmaps = icon.icon_mipmaps or 0,
      scale = 1,
      shift = shift or {0,5}
    },
    {
      icon = "__Molten_Metals__/graphics/technology/molten-drop.png",
      icon_size = size,
      scale = 1*scale,
      shift = {0,0}
    },
  }
end

-- log(serpent.block(technology_icon_compose("aluminum-6061")))