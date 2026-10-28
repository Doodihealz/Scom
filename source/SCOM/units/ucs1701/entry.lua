UnitTemplate = Import("scom/units/ucs1701/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs1701", "SCOM unit identity mismatch: ucs1701")
