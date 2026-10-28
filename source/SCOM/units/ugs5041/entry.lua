UnitTemplate = Import("scom/units/ugs5041/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5041", "SCOM unit identity mismatch: ugs5041")
