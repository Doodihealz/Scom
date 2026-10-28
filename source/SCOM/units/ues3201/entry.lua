UnitTemplate = Import("scom/units/ues3201/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues3201", "SCOM unit identity mismatch: ues3201")
