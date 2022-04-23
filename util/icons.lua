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

-- NOTE: The methods do NOT validate your data!; get() replaced metatable
ylib.icon.icons = {
  ---Returns an icon object, Use ``icons:get(...)``
  ---@param self table icons table
  ---@param mod_name string concatenates into ``"__"..mod_name.."__"``
  ---@param icon_name string
  ---@param scale? integer
  ---@param shift? vector
  ---@param tint? color
  ---@return icon - if the icon/key is ``nil`` the missing icon data is returned
  get = function (self, mod_name, icon_name, scale, shift, tint)
    local proto = {} ---@type icon
    if self[mod_name] and self[mod_name][icon_name] then
      proto.icon          = self[mod_name][icon_name].icon
      proto.icon_size     = self[mod_name][icon_name].icon_size
      proto.icon_mipmaps  = self[mod_name][icon_name].icon_mipmaps
      proto.scale         = scale or self[mod_name][icon_name].scale
      proto.shift         = shift or self[mod_name][icon_name].shift
      proto.tint          = tint or self[mod_name][icon_name].tint
    else
      proto = self.ylib.missing
    end
    return proto
  end,
---Adds or overwrites icon data
---
---concatenates ``"__"..mod_name.."__/"..icon_path.."/"..icon_name..".png"`` as field ``icon``
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
    local t_icon = {icon = "__"..mod_name.."__/"..icon_path.."/"..icon_name..".png", icon_size = size or 64, icon_mipmaps = mipmaps or 4, scale = scale or 0.5,
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
  ---@param mod_icon string the key for the new link
  ---@param parent_name string the name of the mod to link to
  ---@param parent_icon string icon name to link
  alias = function (self, mod_name, mod_icon, parent_name, parent_icon)
    self[mod_name] = self[mod_name] or {[mod_icon] = {}}
    self[mod_name][mod_icon] = self[parent_name][parent_icon]
  end,
}
ylib.icon.icons:add("ylib", "graphics/icons", "electric-interface")
ylib.icon.icons:add("ylib", "graphics/icons", "steam-interface")
ylib.icon.icons:add("ylib", "graphics/icons", "missing")
ylib.icon.icons:add("ylib", "graphics/icons", "missing-tech", 128, 0, 1)
ylib.icon.icons:add("ylib", "graphics/icons", "filter", 64, 2, 0.5)


-- --create a map with all types containing icon data
-- local types_with_icon = {}
-- for k, v in pairs(data.raw) do
--   for _, value in pairs(v) do
--     if value.icon or value.icons then
--       types_with_icon[k] = true
--     end
--   end
-- end


---Returns the icon data variant. Use the wrapper functions if possible.
---@param name string ``data.raw[type_table][name]``
---@param type_table? string if not set, uses the first matching type through ``ylib.util.get_type(name)``
---@param main_product? string ``false`` - use main_product's icon if the recipe has none
---@param icons_index? string ``1`` - the index of ``name{ icons{...}}`` to use
---@return table ``{icon: boolean, icons: boolean}``
function ylib.icon.get_icon(name, type_table, main_product, icons_index)
  type_table = type_table or ylib.util.get_item_type(name)
  icons_index = icons_index or 1
  main_product = main_product or false
  local _t = data.raw[type_table]
  local icon = ylib.icon.icons:get("ylib", "missing")
  if _t then
    if _t[name] then
      if _t[name].icon then -- icons on items are mandatory
        icon.icon = _t[name].icon
        icon.icon_size = _t[name].icon_size
        icon.icon_mipmaps = _t[name].icon_mipmaps or 0
        icon.scale = (32/_t[name].icon_size)
      elseif _t[name].icons then
        ylib.util.table_merge(icon, _t[name].icons[icons_index])
      elseif main_product and type_table == "recipe" then --?- search recipes too
        local _mp = ylib.recipe.get_main_product(name)[1] or name
        local _type = ylib.util.get_item_type(_mp)
        _mp = ylib.icon.get_icon(_type, _mp)
        ylib.util.table_merge(icon, _mp)
      end
    else info("Not found: data.raw."..type_table.."."..tostring(name)) end
  else info("Not found: data.raw."..tostring(type_table)) end
  return icon
end


---Returns the icon data of a recipe
---@param recipe_name string
---@param icons_index? integer
---@param main_product? boolean ``true`` - use the main_product if the recipe has no icon
---@return icon
function ylib.icon.get_recipe_icon(recipe_name, icons_index, main_product)
  icons_index = icons_index or 1
  main_product = main_product or true
  return ylib.icon.get_icon(recipe_name, "recipe", main_product, icons_index)
end


---Returns the icon data of an item
---@param item_name string
---@param icons_index? integer which index in icons to return
---@return icon
function ylib.icon.get_item_icon(item_name, icons_index)
  icons_index = icons_index or 1
  return ylib.icon.get_icon(item_name, "item", false, icons_index)
end


---Returns the icon data of a fluid.
---@param fluid_name string
---@param icons_index? integer which index in icons to return
---@return icon
function ylib.icon.get_fluid_icon(fluid_name, icons_index)
  icons_index = icons_index or 1
  return ylib.icon.get_icon(fluid_name, "fluid", false, icons_index)
end



--//TODO rework icon layering at some point

-- ---Returns a table of 2 icons layered on top
-- ---@param icon_top icon use ylib.icon.icons:get() if possible, can work on strings
-- ---@param icon_bottom icon defaults to molten_drop (based on icon_top.icon_size)
-- ---@param size integer preferred size of the icons (will calc a scale value based on this)
-- ---@param shift? table ``{{0,0}, {0,0}}`` - Example: icon_top: ``{2,5}`` icon_bottom: ``{-2,-5}``
-- function ylib.icon.get_composed_icon(icon_top, icon_bottom, size, shift)
--   shift = shift or {{0,0}, {0,0}}

--   if type(icon_top) == "string" then
--     icon_top = ylib.icon.get_recipe_icon(icon_top) or ylib.icon.get_fluid_icon(icon_top) or ylib.icon.icons:get(icon_top)
--   end

--   local function determine_icon_by_type()
--     if icon_top.icon_size <= 96 then return ylib.icon.icons:get("molten_drop")
--     else return ylib.icon.icons:get("molten_drop_tech") end
--   end

--   icon_top.scale = icon_top.scale and icon_top.scale-0.2 or 0.6
--   icon_top.scale = icon_top.scale*scale
--   icon_top.shift = {0,0-shift}
--   icon_bottom = icon_bottom or determine_icon_by_type()
--   -- icon_bottom.scale = (icon_bottom.icon_size/icon_top.icon_size)*(scale-0.2)
--   icon_bottom.scale = (icon_bottom.icon_size/icon_top.icon_size)*(scale*0.6)
--   icon_bottom.shift = {0,0+shift}

--   return {icon_top, icon_bottom}
-- end

