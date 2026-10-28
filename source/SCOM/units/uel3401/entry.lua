UnitTemplate = Import("scom/units/uel3401/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uel3401", "SCOM unit identity mismatch: uel3401")
