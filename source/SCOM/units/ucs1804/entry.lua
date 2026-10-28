UnitTemplate = Import("scom/units/ucs1804/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs1804", "SCOM unit identity mismatch: ucs1804")
