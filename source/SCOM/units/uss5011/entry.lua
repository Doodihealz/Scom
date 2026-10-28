UnitTemplate = Import("scom/units/uss5011/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss5011", "SCOM unit identity mismatch: uss5011")
