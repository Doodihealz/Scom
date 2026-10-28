UnitTemplate = Import("scom/units/usa1201/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usa1201", "SCOM unit identity mismatch: usa1201")
