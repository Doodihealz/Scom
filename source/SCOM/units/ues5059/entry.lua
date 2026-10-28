UnitTemplate = Import("scom/units/ues5059/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5059", "SCOM unit identity mismatch: ues5059")
