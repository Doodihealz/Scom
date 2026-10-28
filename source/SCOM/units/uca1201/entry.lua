UnitTemplate = Import("scom/units/uca1201/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uca1201", "SCOM unit identity mismatch: uca1201")
