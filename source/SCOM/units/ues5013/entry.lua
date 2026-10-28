UnitTemplate = Import("scom/units/ues5013/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5013", "SCOM unit identity mismatch: ues5013")
