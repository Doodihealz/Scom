UnitTemplate = Import("scom/units/ugs2611/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs2611", "SCOM unit identity mismatch: ugs2611")
