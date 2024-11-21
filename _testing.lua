-- simple tests

local t = {"crude-oil", "water", "lubricant", "cargo-waggon"}
local fluids = ylib.fluid.get_fluids()


log("---- UTIL TESTS ----")

log("is_in_list() + get_fluids()")
  for key, value in pairs(t) do
    if ylib.util.is_in_list(value, fluids) then log(value.." - OK") else log(value.." - FAIL") end
  end

log("get_machine_type()")
  if ylib.util.get_machine_type(data.raw["assembling-machine"]["chemical-plant"].name) == "assembling-machine" then
    log("chemical-plant - OK")
  else
    log("chemical-plant - FAIL")
  end


log("---- FLUID TESTS ----")

log("is_fluid()")
  for key, value in pairs(t) do
    if ylib.fluid.is_fluid(value) then log(value.." - OK") else log(value.." - FAIL") end
  end

log("has_fluid_box()")
  t = {"assembling-machine-2", "chemical-plant", "cargo-waggon"}
  for key, value in pairs(t) do
    if ylib.fluid.has_fluid_box(value) then log(value.." - OK") else log(value.." - FAIL") end
  end

log("get_fluid_box_production_types()")
  t = {"pump", "chemical-plant", "cargo-waggon"}
  for key, value in pairs(t) do
    if ylib.fluid.get_fluid_box_production_types(value, "input") then log(value.." - in OK") else log(value.." - FAIL") end
    if ylib.fluid.get_fluid_box_production_types(value, "output") then log(value.." - out OK") else log(value.." - FAIL") end
  end


error("END OF TESTS")