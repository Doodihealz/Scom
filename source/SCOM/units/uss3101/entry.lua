UnitTemplate = Import("scom/units/uss3101/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss3101", "SCOM unit identity mismatch: uss3101")
