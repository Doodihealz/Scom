UnitTemplate = Import("scom/units/ucs1802/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs1802", "SCOM unit identity mismatch: ucs1802")
