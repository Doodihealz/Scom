UnitTemplate = Import("scom/units/uel5007/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uel5007", "SCOM unit identity mismatch: uel5007")
