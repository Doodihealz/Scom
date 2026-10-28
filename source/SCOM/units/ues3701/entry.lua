UnitTemplate = Import("scom/units/ues3701/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues3701", "SCOM unit identity mismatch: ues3701")
