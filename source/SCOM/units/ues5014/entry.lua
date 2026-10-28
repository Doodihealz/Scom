UnitTemplate = Import("scom/units/ues5014/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5014", "SCOM unit identity mismatch: ues5014")
