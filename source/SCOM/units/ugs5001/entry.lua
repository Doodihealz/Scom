UnitTemplate = Import("scom/units/ugs5001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5001", "SCOM unit identity mismatch: ugs5001")
