
---Returns the type
---@param name string
---@return string
function ylib.util.get_type(name)
  local type_name = nil
  if type(name) == "string" then
    local type_list = {
      "ammo", "armor", "capsule", "fluid", "gun", "item", "mining-tool", "repair-tool", "module", "tool",
      "item-with-entity-data", "rail-planner", "item-with-label", "item-with-inventory", "blueprint-book",
      "item-with-tags", "selection-tool", "blueprint", "copy-paste-tool", "deconstruction-item", "upgrade-item",
      "spidertron-remote"
    }
    for _, _t in pairs(type_list) do
      if data.raw[_t][name] then type_name = _t end
    end
  else
    log("Parameter Name is not a string")
  end
  return type_name
end


---Hopefully returns the entity type
---@param entity_name string
---@return string|nil
function ylib.util.get_entity_type(entity_name)
  for entity_type, _ in pairs(data.raw) do
    for entity, _ in pairs(data.raw[entity_type]) do
      if entity == entity_name --TODO check positives instead?
      and entity_type ~= "item"
      and entity_type ~= "fluid"
      and entity_type ~= "recipe"
      then
          return entity_type
      end
    end
  end
  return nil
end


---Returns true if value is in list, else returns false
---@param value string
---@param list table
---@return boolean
function ylib.util.is_in_list (value, list)
  for _, v in pairs (list) do
    if value == v then return true end
  end
  return false
end


---Returns a table containing all minable recources(*basic-solid only!*); removes the ones specified in the **blacklist**
---@param filter? boolean
---@return table
function get_minable_resouces(filter)
  local blacklist = { --//*FIXME blacklist must be outside of function
    ores = {"coal"},
    recipes = {"concrete"}
  }
  filter = filter or true
  local minable_resources = {}

  for key, value in pairs(data.raw.resource) do
    minable_resources[key] = {name=key, type=value.category or "basic-solid", results={}}
    if value.minable.result then
      local _name = value.minable.result
      local _type = value.minable.type or "item"
      minable_resources[key].results = {{name=_name, type=_type}}
    end
    if value.minable.results then
      for j, result in ipairs(value.minable.results) do
        minable_resources[key].results[j] = {type=result.type, name=result.name}
      end
    end
  end
  if filter then
    for _, name in ipairs(blacklist.ores) do
      for key, value in pairs(minable_resources) do
        if name == key then -- find isnt strict enough
          minable_resources[key] = nil
        end
        if tostring(value.type) ~= "basic-solid" then
          minable_resources[key] = nil
        end
      end
    end
    return minable_resources
  else
    return minable_resources
  end
end
-- log(serpent.block(get_minable_resouces()))
-- error("get_all_minable_resouces()")


---Returns wether or not a given resource is minable (is an ore)
---@param name string ore name
---@param resources? table get_minable_resources()
function is_ore(name, resources)
  resources = resources or get_minable_resouces(true)

  for key, table in pairs(resources) do
    for _, result in ipairs(table.results) do -- maybe modded resources have more than 1 result
      if result.name == name then return true end
    end
  end

  return false
end


