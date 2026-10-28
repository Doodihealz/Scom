UnitTemplate = Import("scom/units/uss5017/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss5017", "SCOM unit identity mismatch: uss5017")
