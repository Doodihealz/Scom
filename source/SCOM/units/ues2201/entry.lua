UnitTemplate = Import("scom/units/ues2201/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues2201", "SCOM unit identity mismatch: ues2201")
