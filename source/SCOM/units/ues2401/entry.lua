UnitTemplate = Import("scom/units/ues2401/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues2401", "SCOM unit identity mismatch: ues2401")
