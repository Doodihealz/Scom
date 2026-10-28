UnitTemplate = Import("scom/units/ucs1702/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs1702", "SCOM unit identity mismatch: ucs1702")
