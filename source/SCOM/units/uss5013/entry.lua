UnitTemplate = Import("scom/units/uss5013/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss5013", "SCOM unit identity mismatch: uss5013")
