UnitTemplate = Import("scom/units/uca3011/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uca3011", "SCOM unit identity mismatch: uca3011")
