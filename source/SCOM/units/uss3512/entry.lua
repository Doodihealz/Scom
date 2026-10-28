UnitTemplate = Import("scom/units/uss3512/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss3512", "SCOM unit identity mismatch: uss3512")
