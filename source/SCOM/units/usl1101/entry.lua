UnitTemplate = Import("scom/units/usl1101/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usl1101", "SCOM unit identity mismatch: usl1101")
