UnitTemplate = Import("scom/units/ugs5054/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5054", "SCOM unit identity mismatch: ugs5054")
