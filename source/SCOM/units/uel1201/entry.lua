UnitTemplate = Import("scom/units/uel1201/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uel1201", "SCOM unit identity mismatch: uel1201")
