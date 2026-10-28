UnitTemplate = Import("scom/units/ugs5015/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5015", "SCOM unit identity mismatch: ugs5015")
