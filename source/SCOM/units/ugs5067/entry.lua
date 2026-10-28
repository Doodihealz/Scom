UnitTemplate = Import("scom/units/ugs5067/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5067", "SCOM unit identity mismatch: ugs5067")
