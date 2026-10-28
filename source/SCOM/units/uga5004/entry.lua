UnitTemplate = Import("scom/units/uga5004/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uga5004", "SCOM unit identity mismatch: uga5004")
