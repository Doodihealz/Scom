UnitTemplate = Import("scom/units/uca2011/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uca2011", "SCOM unit identity mismatch: uca2011")
