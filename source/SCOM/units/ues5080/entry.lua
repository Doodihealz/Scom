UnitTemplate = Import("scom/units/ues5080/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5080", "SCOM unit identity mismatch: ues5080")
