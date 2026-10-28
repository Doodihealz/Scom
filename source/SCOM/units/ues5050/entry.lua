UnitTemplate = Import("scom/units/ues5050/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5050", "SCOM unit identity mismatch: ues5050")
