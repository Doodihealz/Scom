UnitTemplate = Import("scom/units/uga5009/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uga5009", "SCOM unit identity mismatch: uga5009")
