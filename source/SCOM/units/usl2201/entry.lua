UnitTemplate = Import("scom/units/usl2201/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usl2201", "SCOM unit identity mismatch: usl2201")
