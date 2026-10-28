UnitTemplate = Import("scom/units/uss5023/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss5023", "SCOM unit identity mismatch: uss5023")
