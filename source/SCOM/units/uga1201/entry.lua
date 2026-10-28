UnitTemplate = Import("scom/units/uga1201/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uga1201", "SCOM unit identity mismatch: uga1201")
