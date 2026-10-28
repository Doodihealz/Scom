UnitTemplate = Import("scom/units/uga5006/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uga5006", "SCOM unit identity mismatch: uga5006")
