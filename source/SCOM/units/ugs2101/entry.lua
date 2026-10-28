UnitTemplate = Import("scom/units/ugs2101/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs2101", "SCOM unit identity mismatch: ugs2101")
