UnitTemplate = Import("scom/units/ues3603/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues3603", "SCOM unit identity mismatch: ues3603")
