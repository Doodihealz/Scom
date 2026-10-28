UnitTemplate = Import("scom/units/ugs5011/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5011", "SCOM unit identity mismatch: ugs5011")
