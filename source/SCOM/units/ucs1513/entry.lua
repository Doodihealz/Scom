UnitTemplate = Import("scom/units/ucs1513/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs1513", "SCOM unit identity mismatch: ucs1513")
