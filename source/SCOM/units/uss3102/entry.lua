UnitTemplate = Import("scom/units/uss3102/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss3102", "SCOM unit identity mismatch: uss3102")
