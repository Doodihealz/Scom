UnitTemplate = Import("scom/units/ues5027/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5027", "SCOM unit identity mismatch: ues5027")
