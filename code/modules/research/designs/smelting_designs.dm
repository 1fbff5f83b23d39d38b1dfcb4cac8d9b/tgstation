///////SMELTABLE ALLOYS///////

/datum/design/plasteel_alloy
	name = "Plasma + Iron alloy"
	id = "plasteel"
	build_type = SMELTER
	materials = list(MAT_METAL = MINERAL_MATERIAL_AMOUNT, MAT_PLASMA = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/plasteel
	category = list("initial")


/datum/design/plastitanium_alloy
	name = "Plasma + Titanium alloy"
	id = "plastitanium"
	build_type = SMELTER
	materials = list(MAT_TITANIUM = MINERAL_MATERIAL_AMOUNT, MAT_PLASMA = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/mineral/plastitanium
	category = list("initial")

/datum/design/plaglass_alloy
	name = "Plasma + Glass alloy"
	id = "plasmaglass"
	build_type = SMELTER
	materials = list(MAT_PLASMA = MINERAL_MATERIAL_AMOUNT * 0.5, MAT_GLASS = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/plasmaglass
	category = list("initial")

/datum/design/plasmarglass_alloy
	name = "Plasma + Metal + Glass alloy"
	id = "plasmareinforcedglass"
	build_type = SMELTER
	materials = list(MAT_PLASMA = MINERAL_MATERIAL_AMOUNT * 0.5, MAT_METAL = MINERAL_MATERIAL_AMOUNT * 0.5,  MAT_GLASS = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/plasmarglass
	category = list("initial")

/datum/design/titaniumglass_alloy
	name = "Titanium + Glass alloy"
	id = "titaniumglass"
	build_type = SMELTER
	materials = list(MAT_TITANIUM = MINERAL_MATERIAL_AMOUNT * 0.5, MAT_GLASS = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/titaniumglass
	category = list("initial")

/datum/design/plastitaniumglass_alloy
	name = "Plasma + Titanium + Glass alloy"
	id = "plastitaniumglass"
	build_type = SMELTER
	materials = list(MAT_PLASMA = MINERAL_MATERIAL_AMOUNT * 0.5, MAT_TITANIUM = MINERAL_MATERIAL_AMOUNT * 0.5, MAT_GLASS = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/plastitaniumglass
	category = list("initial")

/datum/design/alienalloy
	name = "Alien Alloy"
	desc = "A sheet of reverse-engineered alien alloy."
	id = "alienalloy"
	build_type = PROTOLATHE | SMELTER
	materials = list(MAT_METAL = 4000, MAT_PLASMA = 4000)
	build_path = /obj/item/stack/sheet/mineral/abductor
	category = list("Stock Parts")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE
