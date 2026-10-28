UnitTemplate = Import("scom/units/ucs1511/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs1511", "SCOM unit identity mismatch: ucs1511")
