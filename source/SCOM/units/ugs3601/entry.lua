UnitTemplate = Import("scom/units/ugs3601/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs3601", "SCOM unit identity mismatch: ugs3601")
