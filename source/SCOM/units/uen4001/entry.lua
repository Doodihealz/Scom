UnitTemplate = Import("scom/units/uen4001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uen4001", "SCOM unit identity mismatch: uen4001")
