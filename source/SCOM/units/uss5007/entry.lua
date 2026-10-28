UnitTemplate = Import("scom/units/uss5007/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss5007", "SCOM unit identity mismatch: uss5007")
