UnitTemplate = Import("scom/units/ugs3603/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs3603", "SCOM unit identity mismatch: ugs3603")
