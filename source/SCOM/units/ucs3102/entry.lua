UnitTemplate = Import("scom/units/ucs3102/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs3102", "SCOM unit identity mismatch: ucs3102")
