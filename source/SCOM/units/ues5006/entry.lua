UnitTemplate = Import("scom/units/ues5006/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5006", "SCOM unit identity mismatch: ues5006")
