UnitTemplate = Import("scom/units/usa1502/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usa1502", "SCOM unit identity mismatch: usa1502")
