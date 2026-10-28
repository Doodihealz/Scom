UnitTemplate = Import("scom/units/uca3701/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uca3701", "SCOM unit identity mismatch: uca3701")
