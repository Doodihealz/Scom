UnitTemplate = Import("scom/units/ues3511/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues3511", "SCOM unit identity mismatch: ues3511")
