UnitTemplate = Import("scom/units/ues5009/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5009", "SCOM unit identity mismatch: ues5009")
