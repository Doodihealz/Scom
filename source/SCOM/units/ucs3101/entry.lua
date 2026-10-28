UnitTemplate = Import("scom/units/ucs3101/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs3101", "SCOM unit identity mismatch: ucs3101")
