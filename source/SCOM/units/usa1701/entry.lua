UnitTemplate = Import("scom/units/usa1701/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usa1701", "SCOM unit identity mismatch: usa1701")
