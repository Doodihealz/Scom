UnitTemplate = Import("scom/units/uss5010/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss5010", "SCOM unit identity mismatch: uss5010")
