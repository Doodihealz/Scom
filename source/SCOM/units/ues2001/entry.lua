UnitTemplate = Import("scom/units/ues2001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues2001", "SCOM unit identity mismatch: ues2001")
