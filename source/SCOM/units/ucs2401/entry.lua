UnitTemplate = Import("scom/units/ucs2401/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs2401", "SCOM unit identity mismatch: ucs2401")
