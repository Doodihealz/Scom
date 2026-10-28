UnitTemplate = Import("scom/units/ues5076/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5076", "SCOM unit identity mismatch: ues5076")
