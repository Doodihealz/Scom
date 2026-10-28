UnitTemplate = Import("scom/units/ucs1614/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs1614", "SCOM unit identity mismatch: ucs1614")
