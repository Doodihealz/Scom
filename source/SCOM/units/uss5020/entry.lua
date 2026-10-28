UnitTemplate = Import("scom/units/uss5020/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss5020", "SCOM unit identity mismatch: uss5020")
