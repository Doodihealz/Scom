UnitTemplate = Import("scom/units/ues3611/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues3611", "SCOM unit identity mismatch: ues3611")
