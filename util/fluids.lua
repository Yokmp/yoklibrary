


---Returns a list of all fluids
---@param filter? table do only return fluids containing this string
---@return table
function ylib.fluid.get_fluids(filter)
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


---Returns true if the entity has a fluid box
---@param entity_name string
---@param entity_type? string must be set if the entity name exists in multiple types
---@return boolean
function ylib.fluid.has_fluid_box(entity_name, entity_type)
  entity_type = entity_type or ylib.util.get_machine_type(entity_name)
  if data.raw[entity_type][entity_name] then
    return data.raw[entity_type][entity_name].fluid_boxes and true
  end
  return false
end

---Returns true if the entity has a specific type of fluid box
---@param entity_name string
---@param production_type string
---@param entity_type? string must be set if the entity name exists in multiple types
---@return boolean
function ylib.fluid.has_fluid_box_of_type(entity_name, production_type, entity_type)
  entity_type = entity_type or ylib.util.get_machine_type(entity_name)
  if ylib.fluid.has_fluid_box(entity_name, entity_type) then
    for _, fluid_box in ipairs(data.raw[entity_type][entity_name].fluid_boxes) do
      if fluid_box.production_type == production_type then
        return true
      end
    end
    return false
  end
end


---Returns the amount of fluid boxes
---@param entity_name string
---@param entity_type? string
---@return integer
function ylib.fluid.get_fluid_box_amount(entity_name, entity_type)
  entity_type = entity_type or ylib.util.get_machine_type(entity_name)
  if ylib.fluid.has_fluid_box(entity_name, entity_type) then
    return #data.raw[entity_type][entity_name].fluid_boxes
  end
  return 0
end


---Returns the amount of fluid boxes of a type
---@param entity_name string
---@param production_type string
---@param entity_type? string
---@return integer
function ylib.fluid.get_fluid_box_amount_of_type(entity_name, production_type, entity_type)
  entity_type = entity_type or ylib.util.get_machine_type(entity_name)
  local amount = 0
  if ylib.fluid.has_fluid_box_of_type(entity_name, production_type, entity_type) then
    for _, fluid_box in ipairs(data.raw[entity_type][entity_name].fluid_boxes) do
      if fluid_box.production_type == production_type then
        amount = amount+1
      end
    end
  end
  return amount
end

---Returns a table containing the amount of fluid box types
---@param entity_name string
---@param entity_type? string
---@return table ``{none = i, input = i, ["input-output"] = i, output = i,}``
function ylib.fluid.get_fluid_box_types(entity_name, entity_type)
  entity_type = entity_type or ylib.util.get_machine_type(entity_name)
  local amount = {none = 0, input = 0, ["input-output"] = 0, output = 0,}
  if ylib.fluid.has_fluid_box(entity_name, entity_type) then
    for _, value in ipairs(data.raw[entity_type][entity_name].fluid_boxes) do
      amount[value.production_type] = amount[value.production_type]+1
    end
  end
  return amount
end


-- log(serpent.block(get_recipe_result_count("advanced-oil-processing")))
-- error("TEST")