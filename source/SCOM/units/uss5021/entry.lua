UnitTemplate = Import("scom/units/uss5021/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss5021", "SCOM unit identity mismatch: uss5021")
