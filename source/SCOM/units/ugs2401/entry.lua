UnitTemplate = Import("scom/units/ugs2401/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs2401", "SCOM unit identity mismatch: ugs2401")
