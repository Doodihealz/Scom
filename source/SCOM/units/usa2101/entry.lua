UnitTemplate = Import("scom/units/usa2101/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usa2101", "SCOM unit identity mismatch: usa2101")
