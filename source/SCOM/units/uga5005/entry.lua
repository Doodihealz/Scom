UnitTemplate = Import("scom/units/uga5005/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uga5005", "SCOM unit identity mismatch: uga5005")
