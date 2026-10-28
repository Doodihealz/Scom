UnitTemplate = Import("scom/units/ucs2806/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs2806", "SCOM unit identity mismatch: ucs2806")
