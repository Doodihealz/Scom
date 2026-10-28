UnitTemplate = Import("scom/units/ugs5002/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5002", "SCOM unit identity mismatch: ugs5002")
