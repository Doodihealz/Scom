UnitTemplate = Import("scom/units/ugs3501/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs3501", "SCOM unit identity mismatch: ugs3501")
