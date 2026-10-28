UnitTemplate = Import("scom/units/usl2101/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usl2101", "SCOM unit identity mismatch: usl2101")
