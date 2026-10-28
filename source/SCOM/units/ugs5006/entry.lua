UnitTemplate = Import("scom/units/ugs5006/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5006", "SCOM unit identity mismatch: ugs5006")
