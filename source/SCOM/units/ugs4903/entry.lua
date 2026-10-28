UnitTemplate = Import("scom/units/ugs4903/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs4903", "SCOM unit identity mismatch: ugs4903")
