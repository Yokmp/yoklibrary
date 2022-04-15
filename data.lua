ylib = ylib or {}
ylib.recipe = ylib.recipe or {}
ylib.fluid = ylib.fluid or {}
ylib.util = ylib.util or {}
ylib.icon = ylib.icon or {}

loglevel = settings.startup["ylib-logging"].value
require("util.logger")

---create the categories for molten metals


require("util.logger")
require("util.icons")
require("util.util")
require("util.functions")
require("util.fluids")
require("util.technology")
require("recipe.recipe")
require("recipe.exotic")

