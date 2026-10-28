UnitTemplate = Import("scom/units/uel5005/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uel5005", "SCOM unit identity mismatch: uel5005")
