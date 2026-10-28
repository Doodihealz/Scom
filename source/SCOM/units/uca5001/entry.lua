UnitTemplate = Import("scom/units/uca5001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uca5001", "SCOM unit identity mismatch: uca5001")
