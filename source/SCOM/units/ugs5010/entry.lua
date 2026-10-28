UnitTemplate = Import("scom/units/ugs5010/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5010", "SCOM unit identity mismatch: ugs5010")
