UnitTemplate = Import("scom/units/ugs1512/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs1512", "SCOM unit identity mismatch: ugs1512")
