UnitTemplate = Import("scom/units/ugs2201/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs2201", "SCOM unit identity mismatch: ugs2201")
