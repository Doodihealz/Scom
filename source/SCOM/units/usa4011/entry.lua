UnitTemplate = Import("scom/units/usa4011/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usa4011", "SCOM unit identity mismatch: usa4011")
