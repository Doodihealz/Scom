UnitTemplate = Import("scom/units/ues5071/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5071", "SCOM unit identity mismatch: ues5071")
