UnitTemplate = Import("scom/units/ues1612/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues1612", "SCOM unit identity mismatch: ues1612")
