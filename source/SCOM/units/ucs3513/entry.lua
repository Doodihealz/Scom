UnitTemplate = Import("scom/units/ucs3513/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs3513", "SCOM unit identity mismatch: ucs3513")
