UnitTemplate = Import("scom/units/usa3201/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usa3201", "SCOM unit identity mismatch: usa3201")
