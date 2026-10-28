UnitTemplate = Import("scom/units/uga5008/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uga5008", "SCOM unit identity mismatch: uga5008")
