---@class icon
---@field icon string
---@field icon_size integer
---@field icon_mipmaps integer
---@field scale number
---@field shift vector
---@field tint color

---@class vector
---@field table number

---@class color
---@field r number
---@field g number
---@field b number
---@field a number

-- NOTE: The functions do NOT validate your data!
ylib.icon.icons = {
  ---Returns an icon object, Use ``icons:get(name, ...)``
  ---@param self table icons table
  ---@param mod_name string concatenates into ``"__"..mod_name.."__"``
  ---@param icon string
  ---@param scale? integer
  ---@param shift? vector
  ---@param tint? color
  ---@return icon - if the icon/key is ``nil`` the missing icon data is returned
  get = function (self, mod_name, icon, scale, shift, tint)
    local proto = {} ---@type icon
    icon = self[mod_name][icon] and icon or "missing"
    proto.icon          = self[mod_name][icon].path.."/"..self[mod_name][icon].icon..".png"
    proto.icon_size     = self[mod_name][icon].icon_size or 64
    proto.icon_mipmaps  = self[mod_name][icon].icon_mipmaps or 0
    proto.scale         = scale or self[mod_name][icon].scale or 32/proto.icon_size
    proto.shift         = shift or self[mod_name][icon].shift or {0,0}
    proto.tint          = tint or self[mod_name][icon].tint or { r = 1.0, g = 1.0, b = 1.0, a = 1.0 }
    return proto
  end,
---Adds or overwrites icon data
---@param self table
---@param mod_name string
---@param icon_path string
---@param icon_name string
---@param size? integer
---@param mipmaps? integer
---@param scale? number
---@param shift? vector
---@param tint? color
  add = function (self, mod_name, icon_path, icon_name, size, mipmaps, scale, shift, tint)
    local t_icon = {icon = icon_name, path = "__"..mod_name.."__/"..icon_path, icon_size = size or 64, icon_mipmaps = mipmaps or 4, scale = scale or 0.5,
                    shift = shift or {0,0}, tint = tint or { r = 1.0, g = 1.0, b = 1.0, a = 1.0 }}
    if self[mod_name] then
      self[mod_name][icon_name] = t_icon
    else
      self[mod_name] = {[icon_name] = t_icon}
    end
  end,
  ---Creates an alias for an icon (this is not a copy)
  ---@param self table
  ---@param mod_name string this mods name
  ---@param parent_name string the name of the mod to link to
  ---@param parent_icon string icon name to link
  alias = function (self, mod_name, parent_name, parent_icon)
    self[mod_name] = self[mod_name] or {}
    self[mod_name][parent_icon] = self[parent_name][parent_icon]
  end,
}
ylib.icon.icons:add("ylib", "graphics/icons", "electric-interface")
ylib.icon.icons:add("ylib", "graphics/icons", "steam-interface")
ylib.icon.icons:add("ylib", "graphics/icons", "missing")
ylib.icon.icons:add("ylib", "graphics/icons", "missing-tech", 128, 0, 1)


-- ---wrapper
-- local function get_icon(icon_name)
--   return ylib.icon.icons:get("ylib", icon_name)
-- end


function ylib.icon.new_icon()
  return ylib.icon.icons:get("ylib", "missing")
end


---Returns the icon data variant
---@param type_table string
---@param name string
---@return table ``{icon: boolean, icons: boolean}``
function ylib.icon.has_icon(type_table, name) -- I don't know why someone should ever use this
  local _t = data.raw[type_table]
  local _r = {false, false}
  if _t then
    if _t[name] then
      if _t[name].icon then
        _r[1] = true
      elseif _t[name].icons then
        _r[2] = true
      end
    else info("Not found: data.raw."..type_table.."."..name) end
  else info("Not found: data.raw."..type_table) end
  return _r
end


--//TODO Wrapper function instead of 3 similar functions ...


---Returns the icon data of a recipe
---@param recipe_name string
---@param icons_index? integer
---@param item_icons? boolean get the item icon as a fallback
---@return icon
function ylib.icon.get_recipe_icon(recipe_name, icons_index, item_icons)
  icons_index = icons_index or 1
  item_icons = item_icons or false
  local _t = data.raw.recipe[recipe_name]
  local icon = ylib.icon.icons:get("ylib", "missing")
  if _t then
    if _t.icon then
      icon.icon         = _t.icon
      icon.icon_size    = _t.icon_size
      icon.icon_mipmaps = _t.icon_mipmaps or 0
      icon.scale        = (32/_t.icon_size)
    elseif _t.icons then
      ylib.util.table_merge(icon, _t.icons[icons_index])
    elseif item_icons then
      local _mp = {recipe_name, recipe_name}
      if ylib.recipe.get_main_product(recipe_name) then
        _mp = ylib.recipe.get_main_product(recipe_name)
      end
      recipe_name = _mp[1]
      _t = ylib.icon.get_item_icon(_mp[1])
      ylib.util.table_merge(icon, _t.icons)
      icon.tint = _t.icons[icons_index].tint
    end
      info("Using icon: "..recipe_name.." - "..icon.icon)
  else
    info("Item "..recipe_name.." not found, using missing.png icon.")
  end
  return icon
end


---Returns the icon data of an item
---@param item_name string
---@param icons_index? integer
---@return icon
function ylib.icon.get_item_icon(item_name, icons_index)
  icons_index = icons_index or 1
  local _t = data.raw.item[item_name]
  local icon = ylib.icon.icons:get("ylib", "missing")
  if _t then
    if _t.icon then -- icons on items are mandatory --//?search recipes too?
      icon.icon = _t.icon
      icon.icon_size = _t.icon_size
      icon.icon_mipmaps = _t.icon_mipmaps or 0
      icon.scale = (32/_t.icon_size)
    elseif _t.icons then
      ylib.util.table_merge(icon, _t.icons[icons_index])
      icon.tint = _t.icons[icons_index].tint
    end
      info("Using icon: "..item_name.." - "..icon.icon)
  else
    info("Item "..item_name.." not found, using missing.png icon.")
  end
  return icon
end


---Returns the icon data of a fluid.
---@param fluid_name string
---@param icons_index? integer
---@return icon
function ylib.icon.get_fluid_icon(fluid_name, icons_index)
  icons_index = icons_index or 1
  local _t = data.raw.fluid[fluid_name]
  local icon = ylib.icon.icons:get("ylib", "missing")
  if _t then
    if _t.icon then
      icon.icon         = _t.icon
      icon.icon_size    = _t.icon_size
      icon.icon_mipmaps = _t.icon_mipmaps or 0
      icon.scale        = (32/_t.icon_size)
    elseif _t.icons then
      ylib.util.table_merge(icon, _t.icons[icons_index])
      icon.tint = _t.icons[icons_index].tint
    end
  else
    info("Fluid "..fluid_name.." not found, using missing.png icon.")
  end
  return icon
end




--//TODO rework icon layering at some point

---Returns a table containing icon definitions.
---If ``icon_top`` is a string: ``icon_top = get_icon_from_item(icon_top) or get_fluid_icon(icon_top) or icons:get(icon_top)``
---@param icon_top icon|string use ylib.icon.icons:get() if possible, can work on strings
---@param icon_bottom? icon defaults to molten_drop (based on icon_top.icon_size)
---@param shift? table default ``{{0,0}, {0,5}}``
function ylib.icon.get_composed_icon(icon_top, icon_bottom, scale, shift) --//*FIXME drop scaling, should consider making custom icons per metal
  scale = scale or 0.5
  shift = shift or 0

  if type(icon_top) == "string" then
    icon_top = ylib.icon.get_icon_from_item(icon_top) or ylib.icon.get_fluid_icon(icon_top) or ylib.icon.icons:get(icon_top)
  end

  local function determine_icon_by_type()
    if icon_top.icon_size <= 96 then return ylib.icon.icons:get("molten_drop")
    else return ylib.icon.icons:get("molten_drop_tech") end
  end

  icon_top.scale = icon_top.scale and icon_top.scale-0.2 or 0.6
  icon_top.scale = icon_top.scale*scale
  icon_top.shift = {0,0-shift}
  icon_bottom = icon_bottom or determine_icon_by_type()
  -- icon_bottom.scale = (icon_bottom.icon_size/icon_top.icon_size)*(scale-0.2)
  icon_bottom.scale = (icon_bottom.icon_size/icon_top.icon_size)*(scale*0.6)
  icon_bottom.shift = {0,0+shift}

  return {icon_top, icon_bottom}
end

