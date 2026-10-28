UnitTemplate = Import("scom/units/usl4004/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usl4004", "SCOM unit identity mismatch: usl4004")
