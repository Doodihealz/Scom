UnitTemplate = Import("scom/units/ucs2102/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs2102", "SCOM unit identity mismatch: ucs2102")
