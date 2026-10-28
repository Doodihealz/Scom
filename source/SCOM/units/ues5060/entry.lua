UnitTemplate = Import("scom/units/ues5060/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5060", "SCOM unit identity mismatch: ues5060")
