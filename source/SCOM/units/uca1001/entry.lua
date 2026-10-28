UnitTemplate = Import("scom/units/uca1001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uca1001", "SCOM unit identity mismatch: uca1001")
