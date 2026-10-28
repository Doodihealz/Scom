UnitTemplate = Import("scom/units/uga5001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uga5001", "SCOM unit identity mismatch: uga5001")
