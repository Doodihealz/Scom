UnitTemplate = Import("scom/units/uca2806/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uca2806", "SCOM unit identity mismatch: uca2806")
