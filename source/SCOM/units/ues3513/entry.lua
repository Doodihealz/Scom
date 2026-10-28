UnitTemplate = Import("scom/units/ues3513/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues3513", "SCOM unit identity mismatch: ues3513")
