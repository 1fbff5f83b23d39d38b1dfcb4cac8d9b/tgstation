

//Glorified teleporter that puts you in a new human body.
// it's """VR"""
/obj/machinery/vr_sleeper
	name = "virtual reality sleeper"
	desc = "A sleeper modified to alter the subconscious state of the user, allowing them to visit virtual worlds."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	state_open = TRUE
	anchored = TRUE
	occupant_typecache = list(/mob/living/carbon/human) // turned into typecache in Initialize
	circuit = /obj/item/circuitboard/machine/vr_sleeper
	var/you_die_in_the_game_you_die_for_real = FALSE
	var/datum/effect_system/spark_spread/sparks
	var/mob/living/carbon/human/virtual_reality/vr_human
	var/static/list/available_vr_spawnpoints
	var/vr_category = "default" //Specific category of spawn points to pick from
	var/allow_creating_vr_humans = TRUE //So you can have vr_sleepers that always spawn you as a specific person or 1 life/chance vr games

/obj/machinery/vr_sleeper/Initialize()
	. = ..()
	sparks = new /datum/effect_system/spark_spread()
	sparks.set_up(2,0)
	sparks.attach(src)
	build_spawnpoints()
	update_icon()

/obj/machinery/vr_sleeper/attackby(obj/item/I, mob/user, params)
	if(!state_open && !occupant)
		if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), I))
			return
	if(default_change_direction_wrench(user, I))
		return
	if(default_pry_open(I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/vr_sleeper/relaymove(mob/user)
	open_machine()

/obj/machinery/vr_sleeper/container_resist(mob/living/user)
	open_machine()

/obj/machinery/vr_sleeper/Destroy()
	open_machine()
	cleanup_vr_human()
	QDEL_NULL(sparks)
	return ..()

/obj/machinery/vr_sleeper/hugbox
	desc = "A sleeper modified to alter the subconscious state of the user, allowing them to visit virtual worlds. Seems slightly more secure."
	flags_1 = NODECONSTRUCT_1

/obj/machinery/vr_sleeper/hugbox/emag_act(mob/user)
	return

/obj/machinery/vr_sleeper/emag_act(mob/user)
	you_die_in_the_game_you_die_for_real = TRUE
	sparks.start()

/obj/machinery/vr_sleeper/update_icon()
	icon_state = "[initial(icon_state)][state_open ? "-open" : ""]"

/obj/machinery/vr_sleeper/open_machine()
	if(!state_open)
		if(vr_human)
			vr_human.revert_to_reality(FALSE)
		if(occupant)
			SStgui.close_user_uis(occupant, src)
		..()

/obj/machinery/vr_sleeper/MouseDrop_T(mob/target, mob/user)
	if(user.stat || user.lying || !Adjacent(user) || !user.Adjacent(target) || !iscarbon(target) || !user.IsAdvancedToolUser())
		return
	close_machine(target)

/obj/machinery/vr_sleeper/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "vr_sleeper", "VR Sleeper", 475, 340, master_ui, state)
		ui.open()

/obj/machinery/vr_sleeper/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("vr_connect")
			var/mob/living/carbon/human/human_occupant = occupant
			if(human_occupant && human_occupant.mind)
				to_chat(occupant, "<span class='warning'>Transferring to virtual reality...</span>")
				if(vr_human)
					SStgui.close_user_uis(occupant, src)
					vr_human.revert_to_reality(FALSE)
					vr_human.real_mind = human_occupant.mind
					vr_human.ckey = human_occupant.ckey
					to_chat(vr_human, "<span class='notice'>Transfer successful! you are now playing as [vr_human] in VR!</span>")
				else
					if(allow_creating_vr_humans)
						to_chat(occupant, "<span class='warning'>Virtual avatar not found, attempting to create one...</span>")
						var/obj/effect/landmark/vr_spawn/V = get_vr_spawnpoint()
						var/turf/T = get_turf(V)
						if(T)
							SStgui.close_user_uis(occupant, src)
							build_virtual_human(occupant, T, V.vr_outfit)
							to_chat(vr_human, "<span class='notice'>Transfer successful! you are now playing as [vr_human] in VR!</span>")
						else
							to_chat(occupant, "<span class='warning'>Virtual world misconfigured, aborting transfer</span>")
					else
						to_chat(occupant, "<span class='warning'>The virtual world does not support the creation of new virtual avatars, aborting transfer</span>")
			. = TRUE
		if("delete_avatar")
			if(!occupant || usr == occupant)
				if(vr_human)
					QDEL_NULL(vr_human)
			else
				to_chat(usr, "<span class='warning'>The VR Sleeper's safeties prevent you from doing that.</span>")
			. = TRUE
		if("toggle_open")
			if(state_open)
				close_machine()
			else
				open_machine()
			. = TRUE

/obj/machinery/vr_sleeper/ui_data(mob/user)
	var/list/data = list()
	if(vr_human && !QDELETED(vr_human))
		data["can_delete_avatar"] = TRUE
		var/status
		switch(user.stat)
			if(CONSCIOUS)
				status = "Conscious"
			if(DEAD)
				status = "Dead"
			if(UNCONSCIOUS)
				status = "Unconscious"
		data["vr_avatar"] = list("name" = vr_human.name, "status" = status, "health" = vr_human.health, "maxhealth" = vr_human.maxHealth)
	data["toggle_open"] = state_open
	data["isoccupant"] = (user == occupant)
	return data

/obj/machinery/vr_sleeper/proc/get_vr_spawnpoint() //proc so it can be overriden for team games or something
	return safepick(available_vr_spawnpoints[vr_category])

/obj/machinery/vr_sleeper/proc/build_spawnpoints(rebuild = FALSE) 
	if (rebuild)
		available_vr_spawnpoints = null
	if(!available_vr_spawnpoints || !available_vr_spawnpoints.len) //(re)build spawnpoint lists
		available_vr_spawnpoints = list()
		for(var/obj/effect/landmark/vr_spawn/V in GLOB.landmarks_list)
			LAZYADD(available_vr_spawnpoints[V.vr_category], V)

/obj/machinery/vr_sleeper/proc/build_virtual_human(mob/living/carbon/human/H, location, var/datum/outfit/outfit, transfer = TRUE)
	if(H)
		cleanup_vr_human()
		vr_human = new /mob/living/carbon/human/virtual_reality(location)
		vr_human.mind_initialize()
		vr_human.vr_sleeper = src
		vr_human.real_mind = H.mind
		H.dna.transfer_identity(vr_human)
		vr_human.name = H.name
		vr_human.real_name = H.real_name
		vr_human.socks = H.socks
		vr_human.undershirt = H.undershirt
		vr_human.underwear = H.underwear
		vr_human.updateappearance(TRUE, TRUE, TRUE)
		if(outfit)
			var/datum/outfit/O = new outfit()
			O.equip(vr_human)
		if(transfer && H.mind)
			SStgui.close_user_uis(H, src)
			vr_human.ckey = H.ckey

/obj/machinery/vr_sleeper/proc/cleanup_vr_human()
	if(vr_human)
		vr_human.death(FALSE)

/obj/effect/landmark/vr_spawn //places you can spawn in VR, auto selected by the vr_sleeper during get_vr_spawnpoint()
	var/vr_category = "default" //So we can have specific sleepers, eg: "Basketball VR Sleeper", etc.
	var/vr_outfit = /datum/outfit/vr_basic

/obj/effect/landmark/vr_spawn/team_1
	vr_category = "team_1"

/obj/effect/landmark/vr_spawn/team_2
	vr_category = "team_2"	

/datum/outfit/vr_basic
	name = "basic vr"
	uniform = /obj/item/clothing/under/color/random
	shoes = /obj/item/clothing/shoes/sneakers/black
