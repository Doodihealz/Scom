UnitTemplate = Import("scom/units/ugs5004/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5004", "SCOM unit identity mismatch: ugs5004")
