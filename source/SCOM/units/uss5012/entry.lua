UnitTemplate = Import("scom/units/uss5012/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss5012", "SCOM unit identity mismatch: uss5012")
