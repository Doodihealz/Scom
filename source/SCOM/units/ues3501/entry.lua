UnitTemplate = Import("scom/units/ues3501/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues3501", "SCOM unit identity mismatch: ues3501")
