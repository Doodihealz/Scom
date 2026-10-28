UnitTemplate = Import("scom/units/uga5002/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uga5002", "SCOM unit identity mismatch: uga5002")
