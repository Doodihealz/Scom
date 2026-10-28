UnitTemplate = Import("scom/units/ugs5050/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5050", "SCOM unit identity mismatch: ugs5050")
