UnitTemplate = Import("scom/units/usa2502/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usa2502", "SCOM unit identity mismatch: usa2502")
