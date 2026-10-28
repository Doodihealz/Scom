UnitTemplate = Import("scom/units/ugs5057/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5057", "SCOM unit identity mismatch: ugs5057")
