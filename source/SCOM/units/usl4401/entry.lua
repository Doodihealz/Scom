UnitTemplate = Import("scom/units/usl4401/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usl4401", "SCOM unit identity mismatch: usl4401")
