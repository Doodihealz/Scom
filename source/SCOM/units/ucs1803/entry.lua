UnitTemplate = Import("scom/units/ucs1803/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs1803", "SCOM unit identity mismatch: ucs1803")
