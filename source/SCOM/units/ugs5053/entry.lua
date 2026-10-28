UnitTemplate = Import("scom/units/ugs5053/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5053", "SCOM unit identity mismatch: ugs5053")
