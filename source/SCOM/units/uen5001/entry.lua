UnitTemplate = Import("scom/units/uen5001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uen5001", "SCOM unit identity mismatch: uen5001")
