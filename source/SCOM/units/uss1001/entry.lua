UnitTemplate = Import("scom/units/uss1001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss1001", "SCOM unit identity mismatch: uss1001")
