UnitTemplate = Import("scom/units/uss5016/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss5016", "SCOM unit identity mismatch: uss5016")
