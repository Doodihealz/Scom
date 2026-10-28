UnitTemplate = Import("scom/units/uel2201/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uel2201", "SCOM unit identity mismatch: uel2201")
