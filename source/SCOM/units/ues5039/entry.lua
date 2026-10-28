UnitTemplate = Import("scom/units/ues5039/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5039", "SCOM unit identity mismatch: ues5039")
