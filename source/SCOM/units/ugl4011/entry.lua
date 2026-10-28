UnitTemplate = Import("scom/units/ugl4011/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugl4011", "SCOM unit identity mismatch: ugl4011")
