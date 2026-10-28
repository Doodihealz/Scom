UnitTemplate = Import("scom/units/uca2101/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uca2101", "SCOM unit identity mismatch: uca2101")
