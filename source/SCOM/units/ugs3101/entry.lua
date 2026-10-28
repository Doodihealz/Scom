UnitTemplate = Import("scom/units/ugs3101/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs3101", "SCOM unit identity mismatch: ugs3101")
