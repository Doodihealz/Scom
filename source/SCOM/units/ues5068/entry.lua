UnitTemplate = Import("scom/units/ues5068/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5068", "SCOM unit identity mismatch: ues5068")
