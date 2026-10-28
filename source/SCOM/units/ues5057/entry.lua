UnitTemplate = Import("scom/units/ues5057/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5057", "SCOM unit identity mismatch: ues5057")
