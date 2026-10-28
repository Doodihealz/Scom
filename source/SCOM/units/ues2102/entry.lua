UnitTemplate = Import("scom/units/ues2102/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues2102", "SCOM unit identity mismatch: ues2102")
