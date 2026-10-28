UnitTemplate = Import("scom/units/uel5001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uel5001", "SCOM unit identity mismatch: uel5001")
