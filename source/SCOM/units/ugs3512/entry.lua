UnitTemplate = Import("scom/units/ugs3512/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs3512", "SCOM unit identity mismatch: ugs3512")
