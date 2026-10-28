UnitTemplate = Import("scom/units/ugs2102/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs2102", "SCOM unit identity mismatch: ugs2102")
