UnitTemplate = Import("scom/units/ucs2201/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs2201", "SCOM unit identity mismatch: ucs2201")
