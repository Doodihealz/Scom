UnitTemplate = Import("scom/units/ugs5017/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5017", "SCOM unit identity mismatch: ugs5017")
