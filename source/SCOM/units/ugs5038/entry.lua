UnitTemplate = Import("scom/units/ugs5038/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5038", "SCOM unit identity mismatch: ugs5038")
