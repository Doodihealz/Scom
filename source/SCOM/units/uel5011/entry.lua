UnitTemplate = Import("scom/units/uel5011/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uel5011", "SCOM unit identity mismatch: uel5011")
