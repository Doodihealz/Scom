UnitTemplate = Import("scom/units/uss3603/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss3603", "SCOM unit identity mismatch: uss3603")
