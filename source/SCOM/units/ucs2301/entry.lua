UnitTemplate = Import("scom/units/ucs2301/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs2301", "SCOM unit identity mismatch: ucs2301")
