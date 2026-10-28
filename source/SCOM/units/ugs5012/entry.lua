UnitTemplate = Import("scom/units/ugs5012/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5012", "SCOM unit identity mismatch: ugs5012")
