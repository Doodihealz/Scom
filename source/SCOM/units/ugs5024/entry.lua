UnitTemplate = Import("scom/units/ugs5024/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5024", "SCOM unit identity mismatch: ugs5024")
