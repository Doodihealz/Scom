UnitTemplate = Import("scom/units/ues5011/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5011", "SCOM unit identity mismatch: ues5011")
