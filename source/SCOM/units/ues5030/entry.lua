UnitTemplate = Import("scom/units/ues5030/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5030", "SCOM unit identity mismatch: ues5030")
