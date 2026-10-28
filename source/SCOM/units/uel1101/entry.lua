UnitTemplate = Import("scom/units/uel1101/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uel1101", "SCOM unit identity mismatch: uel1101")
