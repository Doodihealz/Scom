UnitTemplate = Import("scom/units/ues5063/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5063", "SCOM unit identity mismatch: ues5063")
