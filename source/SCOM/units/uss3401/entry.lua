UnitTemplate = Import("scom/units/uss3401/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss3401", "SCOM unit identity mismatch: uss3401")
