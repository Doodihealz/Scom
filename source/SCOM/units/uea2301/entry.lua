UnitTemplate = Import("scom/units/uea2301/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uea2301", "SCOM unit identity mismatch: uea2301")
