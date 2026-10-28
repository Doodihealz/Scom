UnitTemplate = Import("scom/units/ugs5064/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5064", "SCOM unit identity mismatch: ugs5064")
