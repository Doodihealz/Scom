UnitTemplate = Import("scom/units/uga5007/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uga5007", "SCOM unit identity mismatch: uga5007")
