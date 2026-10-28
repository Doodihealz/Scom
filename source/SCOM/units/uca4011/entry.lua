UnitTemplate = Import("scom/units/uca4011/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uca4011", "SCOM unit identity mismatch: uca4011")
