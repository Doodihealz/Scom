UnitTemplate = Import("scom/units/ues1511/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues1511", "SCOM unit identity mismatch: ues1511")
