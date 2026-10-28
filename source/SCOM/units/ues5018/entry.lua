UnitTemplate = Import("scom/units/ues5018/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5018", "SCOM unit identity mismatch: ues5018")
