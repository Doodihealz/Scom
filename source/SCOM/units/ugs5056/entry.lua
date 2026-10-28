UnitTemplate = Import("scom/units/ugs5056/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5056", "SCOM unit identity mismatch: ugs5056")
