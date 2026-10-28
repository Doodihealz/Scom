UnitTemplate = Import("scom/units/usa2011/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usa2011", "SCOM unit identity mismatch: usa2011")
