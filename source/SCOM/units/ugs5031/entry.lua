UnitTemplate = Import("scom/units/ugs5031/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5031", "SCOM unit identity mismatch: ugs5031")
