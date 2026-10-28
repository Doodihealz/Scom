UnitTemplate = Import("scom/units/usl0000/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usl0000", "SCOM unit identity mismatch: usl0000")
