UnitTemplate = Import("scom/units/ugs1001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs1001", "SCOM unit identity mismatch: ugs1001")
