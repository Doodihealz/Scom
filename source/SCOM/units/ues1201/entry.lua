UnitTemplate = Import("scom/units/ues1201/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues1201", "SCOM unit identity mismatch: ues1201")
