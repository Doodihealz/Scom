UnitTemplate = Import("scom/units/ues5005/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5005", "SCOM unit identity mismatch: ues5005")
