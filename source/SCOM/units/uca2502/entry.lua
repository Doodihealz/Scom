UnitTemplate = Import("scom/units/uca2502/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uca2502", "SCOM unit identity mismatch: uca2502")
