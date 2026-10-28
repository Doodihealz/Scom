UnitTemplate = Import("scom/units/ugs1612/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs1612", "SCOM unit identity mismatch: ugs1612")
