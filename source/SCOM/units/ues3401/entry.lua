UnitTemplate = Import("scom/units/ues3401/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues3401", "SCOM unit identity mismatch: ues3401")
