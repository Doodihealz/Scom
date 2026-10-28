UnitTemplate = Import("scom/units/ues1611/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues1611", "SCOM unit identity mismatch: ues1611")
