


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

---Checks if the given string is a fluid
---@param fluid string
---@return boolean
function ylib.fluid.is_fluid(fluid)
  for _, value in pairs(ylib.fluid.get_fluids()) do
    if value == fluid then return true end
  end
  return false
end





-- the next functions don't include fluid_box and pipe_connections!


---Returns true if the entity has a fluid box
---@param entity_name string
---@param entity_type? string must be set if the entity name exists in multiple types
---@return boolean
function ylib.fluid.has_fluid_box(entity_name, entity_type)
  entity_type = entity_type or ylib.util.get_machine_type(entity_name)
  if entity_type and data.raw[entity_type][entity_name] then
    return data.raw[entity_type][entity_name].fluid_boxes and true
  end
  return false
end

---Returns true if the entity has a specific type of fluid box
---@param entity_name string
---@param production_type string
---@param entity_type? string must be set if the entity name exists in multiple types
---@return table
function ylib.fluid.get_fluid_box_production_types(entity_name, production_type, entity_type)
  entity_type = entity_type or ylib.util.get_machine_type(entity_name)
  local list = {}
  if ylib.fluid.has_fluid_box(entity_name, entity_type) then
    for _, fluid_box in ipairs(data.raw[entity_type][entity_name].fluid_boxes) do
      if fluid_box.production_type == production_type then
        table.insert(list, production_type)
      end
    end
  end
  return list
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
