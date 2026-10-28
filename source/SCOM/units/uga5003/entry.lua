UnitTemplate = Import("scom/units/uga5003/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uga5003", "SCOM unit identity mismatch: uga5003")
