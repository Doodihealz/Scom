UnitTemplate = Import("scom/units/usl3101/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usl3101", "SCOM unit identity mismatch: usl3101")
