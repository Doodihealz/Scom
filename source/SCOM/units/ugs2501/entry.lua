UnitTemplate = Import("scom/units/ugs2501/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs2501", "SCOM unit identity mismatch: ugs2501")
