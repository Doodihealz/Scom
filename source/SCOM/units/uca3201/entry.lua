UnitTemplate = Import("scom/units/uca3201/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uca3201", "SCOM unit identity mismatch: uca3201")
