UnitTemplate = Import("scom/units/ues5038/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5038", "SCOM unit identity mismatch: ues5038")
