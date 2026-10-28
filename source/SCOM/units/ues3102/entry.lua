UnitTemplate = Import("scom/units/ues3102/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues3102", "SCOM unit identity mismatch: ues3102")
