UnitTemplate = Import("scom/units/ues1701/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues1701", "SCOM unit identity mismatch: ues1701")
