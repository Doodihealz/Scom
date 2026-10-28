UnitTemplate = Import("scom/units/ugs3401/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs3401", "SCOM unit identity mismatch: ugs3401")
