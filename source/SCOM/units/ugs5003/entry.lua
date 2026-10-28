UnitTemplate = Import("scom/units/ugs5003/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5003", "SCOM unit identity mismatch: ugs5003")
