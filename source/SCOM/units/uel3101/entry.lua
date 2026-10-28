UnitTemplate = Import("scom/units/uel3101/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uel3101", "SCOM unit identity mismatch: uel3101")
