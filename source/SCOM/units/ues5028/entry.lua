UnitTemplate = Import("scom/units/ues5028/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5028", "SCOM unit identity mismatch: ues5028")
