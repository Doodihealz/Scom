UnitTemplate = Import("scom/units/uss5019/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss5019", "SCOM unit identity mismatch: uss5019")
