//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/structure/machinery/computer/skills//TODO:SANITY
	name = "Employment Records"
	desc = "Used to view personnel's employment records"
	icon_state = "medlaptop"
	req_one_access = list(ACCESS_MARINE_DATABASE)
	circuit = /obj/item/circuitboard/computer/skills
	var/obj/item/card/id/scan = null
	var/authenticated = null
	var/rank = null
	var/screen = null
	var/datum/data/record/active1 = null
	var/a_id = null
	var/temp = null
	var/printing = null
	var/can_change_id = 0
	var/list/Perp
	var/tempname = null
	//Sorting Variables
	var/sortBy = "name"
	var/order = 1 // -1 = Descending - 1 = Ascending


/obj/structure/machinery/computer/skills/attackby(obj/item/O as obj, user as mob)
	if(istype(O, /obj/item/card/id) && !scan)
		if(usr.drop_held_item())
			O.forceMove(src)
			scan = O
			to_chat(user, "You insert [O].")
	..()

/obj/structure/machinery/computer/skills/attack_remote(mob/user as mob)
	return attack_hand(user)

//Someone needs to break down the dat += into chunks instead of long ass lines.
/obj/structure/machinery/computer/skills/attack_hand(mob/user as mob)
	if(..())
		return
	if (src.z > 6)
		to_chat(user, SPAN_DANGER("<b>Unable to establish a connection</b>: \black You're too far away from the station!"))
		return
	var/dat

	if (temp)
		dat = "<TT>[temp]</TT><BR><BR><A href='?src=\ref[src];choice=Clear Screen'>Clear Screen</A>"
	else
		dat = "Confirm Identity: <A href='?src=\ref[src];choice=Confirm Identity'>[scan ? scan.name : "----------"]</A><HR>"
		if (authenticated)
			switch(screen)
				if(1.0)
					dat += {"
<p style='text-align:center;'>"}
					dat += "<A href='?src=\ref[src];choice=Search Records'>Search Records</A><BR>"
					dat += "<A href='?src=\ref[src];choice=New Record (General)'>New Record</A><BR>"
					dat += {"
</p>
<table style="text-align:center;" cellspacing="0" width="100%">
<tr>
<th>Records:</th>
</tr>
</table>
<table style="text-align:center;" border="1" cellspacing="0" width="100%">
<tr>
<th><A href='?src=\ref[src];choice=Sorting;sort=name'>Name</A></th>
<th><A href='?src=\ref[src];choice=Sorting;sort=id'>ID</A></th>
<th><A href='?src=\ref[src];choice=Sorting;sort=rank'>Rank</A></th>
<th><A href='?src=\ref[src];choice=Sorting;sort=fingerprint'>Fingerprints</A></th>
</tr>"}
					if(!isnull(GLOB.data_core.general))
						for(var/datum/data/record/R in sortRecord(GLOB.data_core.general, sortBy, order))
							for(var/datum/data/record/E in GLOB.data_core.security)
							dat += "<tr><td><A href='?src=\ref[src];choice=Browse Record;d_rec=\ref[R]'>[R.fields["name"]]</a></td>"
							dat += "<td>[R.fields["id"]]</td>"
							dat += "<td>[R.fields["rank"]]</td>"
						dat += "</table><hr width='75%' />"
					dat += "<A href='?src=\ref[src];choice=Record Maintenance'>Record Maintenance</A><br><br>"
					dat += "<A href='?src=\ref[src];choice=Log Out'>{Log Out}</A>"
				if(2.0)
					dat += "<B>Records Maintenance</B><HR>"
					dat += "<BR><A href='?src=\ref[src];choice=Delete All Records'>Delete All Records</A><BR><BR><A href='?src=\ref[src];choice=Return'>Back</A>"
				if(3.0)
					dat += "<CENTER><B>Employment Record</B></CENTER><BR>"
					if ((istype(active1, /datum/data/record) && GLOB.data_core.general.Find(active1)))
						dat += "<table><tr><td> \
						Name: <A href='?src=\ref[src];choice=Edit Field;field=name'>[active1.fields["name"]]</A><BR> \
						ID: <A href='?src=\ref[src];choice=Edit Field;field=id'>[active1.fields["id"]]</A><BR>\n \
						Sex: <A href='?src=\ref[src];choice=Edit Field;field=sex'>[active1.fields["sex"]]</A><BR>\n \
						Age: <A href='?src=\ref[src];choice=Edit Field;field=age'>[active1.fields["age"]]</A><BR>\n \
						Rank: <A href='?src=\ref[src];choice=Edit Field;field=rank'>[active1.fields["rank"]]</A><BR>\n \
						Physical Status: [active1.fields["p_stat"]]<BR>\n \
						Mental Status: [active1.fields["m_stat"]]<BR><BR>\n \
						Employment/skills summary:<BR> [decode(active1.fields["notes"])]<BR></td> \
						<td align = center valign = top>Photo:<br><img src=front.png height=80 width=80 border=4> \
						<img src=side.png height=80 width=80 border=4></td></tr></table>"
					else
						dat += "<B>General Record Lost!</B><BR>"
					dat += "\n<A href='?src=\ref[src];choice=Delete Record (ALL)'>Delete Record (ALL)</A><BR><BR>\n<A href='?src=\ref[src];choice=Print Record'>Print Record</A><BR>\n<A href='?src=\ref[src];choice=Return'>Back</A><BR>"
				if(4.0)
					if(!Perp.len)
						dat += "ERROR.  String could not be located.<br><br><A href='?src=\ref[src];choice=Return'>Back</A>"
					else
						dat += {"
<table style="text-align:center;" cellspacing="0" width="100%">
<tr> "}
						dat += "<th>Search Results for '[tempname]':</th>"
						dat += {"
</tr>
</table>
<table style="text-align:center;" border="1" cellspacing="0" width="100%">
<tr>
<th>Name</th>
<th>ID</th>
<th>Rank</th>
<th>Fingerprints</th>
</tr> "}
						for(var/i=1, i<=Perp.len, i += 2)
							var/crimstat = ""
							var/datum/data/record/R = Perp[i]
							if(istype(Perp[i+1],/datum/data/record/))
								var/datum/data/record/E = Perp[i+1]
								crimstat = E.fields["criminal"]
							dat += "<tr style=background-color:#00FF7F><td><A href='?src=\ref[src];choice=Browse Record;d_rec=\ref[R]'>[R.fields["name"]]</a></td>"
							dat += "<td>[R.fields["id"]]</td>"
							dat += "<td>[R.fields["rank"]]</td>"
							dat += "<td>[crimstat]</td></tr>"
						dat += "</table><hr width='75%' />"
						dat += "<br><A href='?src=\ref[src];choice=Return'>Return to index.</A>"
		else
			dat += "<A href='?src=\ref[src];choice=Log In'>{Log In}</A>"
	show_browser(user, dat, "Employment Records", "secure_rec", "size=600x400")
	onclose(user, "secure_rec")
	return

/*Revised /N
I can't be bothered to look more of the actual code outside of switch but that probably needs revising too.
What a mess.*/
/obj/structure/machinery/computer/skills/Topic(href, href_list)
	if(..())
		return
	if (!( GLOB.data_core.general.Find(active1) ))
		active1 = null
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(loc, /turf))) || (isRemoteControlling(usr)))
		usr.set_interaction(src)
		switch(href_list["choice"])
// SORTING!
			if("Sorting")
				// Reverse the order if clicked twice
				if(sortBy == href_list["sort"])
					if(order == 1)
						order = -1
					else
						order = 1
				else
				// New sorting order!
					sortBy = href_list["sort"]
					order = initial(order)
//BASIC FUNCTIONS
			if("Clear Screen")
				temp = null

			if ("Return")
				screen = 1
				active1 = null

			if("Confirm Identity")
				if (scan)
					if(istype(usr,/mob/living/carbon/human) && !usr.get_active_hand())
						usr.put_in_hands(scan)
					else
						scan.forceMove(get_turf(src))
					scan = null
				else
					var/obj/item/I = usr.get_active_hand()
					if (istype(I, /obj/item/card/id))
						if(usr.drop_held_item())
							I.forceMove(src)
							scan = I

			if("Log Out")
				authenticated = null
				screen = null
				active1 = null

			if("Log In")
				if (isRemoteControlling(usr))
					src.active1 = null
					src.authenticated = usr.name
					src.rank = "AI"
					src.screen = 1
				else if (istype(scan, /obj/item/card/id))
					active1 = null
					if(check_access(scan))
						authenticated = scan.registered_name
						rank = scan.paygrade
						screen = 1
//RECORD FUNCTIONS
			if("Search Records")
				var/t1 = input("Search String: (Partial Name or ID or Fingerprints or Rank)", "Secure. records", null, null)  as text
				if ((!( t1 ) || usr.stat || !( authenticated ) || usr.is_mob_restrained() || !in_range(src, usr)))
					return
				Perp = new/list()
				t1 = lowertext(t1)
				var/list/components = splittext(t1, " ")
				if(components.len > 5)
					return //Lets not let them search too greedily.
				for(var/datum/data/record/R in GLOB.data_core.general)
					var/temptext = R.fields["name"] + " " + R.fields["id"] + " " + R.fields["rank"]
					for(var/i = 1, i<=components.len, i++)
						if(findtext(temptext,components[i]))
							var/prelist = new/list(2)
							prelist[1] = R
							Perp += prelist
				for(var/i = 1, i<=Perp.len, i+=2)
					for(var/datum/data/record/E in GLOB.data_core.security)
						var/datum/data/record/R = Perp[i]
						if ((E.fields["name"] == R.fields["name"] && E.fields["id"] == R.fields["id"]))
							Perp[i+1] = E
				tempname = t1
				screen = 4

			if("Record Maintenance")
				screen = 2
				active1 = null

			if ("Browse Record")
				var/datum/data/record/R = locate(href_list["d_rec"])
				if (!( GLOB.data_core.general.Find(R) ))
					temp = "Record Not Found!"
				else
					for(var/datum/data/record/E in GLOB.data_core.security)
					active1 = R
					screen = 3

			if ("Print Record")
				if (!( printing ))
					printing = 1
					sleep(50)
					var/obj/item/paper/P = new /obj/item/paper( loc )
					P.info = "<CENTER><B>Employment Record</B></CENTER><BR>"
					if ((istype(active1, /datum/data/record) && GLOB.data_core.general.Find(active1)))
						P.info += "Name: [active1.fields["name"]] ID: [active1.fields["id"]]<BR>\nSex: [active1.fields["sex"]]<BR>\nAge: [active1.fields["age"]]<BR>\nPhysical Status: [active1.fields["p_stat"]]<BR>\nMental Status: [active1.fields["m_stat"]]<BR>\nEmployment/Skills Summary:<BR>\n[decode(active1.fields["notes"])]<BR>"
						P.name = "Employment Record ([active1.fields["name"]])"
					else
						P.info += "<B>General Record Lost!</B><BR>"
						P.name = "Employment Record (???)"
					P.info += "</TT>"

					printing = null
//RECORD DELETE
			if ("Delete All Records")
				temp = ""
				temp += "Are you sure you wish to delete all Employment records?<br>"
				temp += "<a href='?src=\ref[src];choice=Purge All Records'>Yes</a><br>"
				temp += "<a href='?src=\ref[src];choice=Clear Screen'>No</a>"

			if ("Purge All Records")
				for(var/datum/data/record/R in GLOB.data_core.security)
					GLOB.data_core.security -= R
					qdel(R)
				temp = "All Employment records deleted."

			if ("Delete Record (ALL)")
				if (active1)
					temp = "<h5>Are you sure you wish to delete the record (ALL)?</h5>"
					temp += "<a href='?src=\ref[src];choice=Delete Record (ALL) Execute'>Yes</a><br>"
					temp += "<a href='?src=\ref[src];choice=Clear Screen'>No</a>"
//RECORD CREATE
			if ("New Record (General)")
				active1 = CreateGeneralRecord()

//FIELD FUNCTIONS
			if ("Edit Field")
				var/a1 = active1
				switch(href_list["field"])
					if("name")
						if (istype(active1, /datum/data/record))
							var/t1 = reject_bad_name(input("Please input name:", "Secure. records", active1.fields["name"], null)  as text)
							if ((!( t1 ) || !length(trim(t1)) || !( authenticated ) || usr.stat || usr.is_mob_restrained() || (!in_range(src, usr) && (!isRemoteControlling(usr)))) || active1 != a1)
								return
							message_admins("[key_name(usr)] has changed the record name of [active1.fields["name"]] to [t1]")
							active1.fields["name"] = t1
					if("id")
						if (istype(active1, /datum/data/record))
							var/t1 = copytext(trim(sanitize(input("Please input id:", "Secure. records", active1.fields["id"], null)  as text)),1,MAX_MESSAGE_LEN)
							if ((!( t1 ) || !( authenticated ) || usr.stat || usr.is_mob_restrained() || (!in_range(src, usr) && (!isRemoteControlling(usr))) || active1 != a1))
								return
							active1.fields["id"] = t1

					if("sex")
						if (istype(active1, /datum/data/record))
							if (active1.fields["sex"] == "Male")
								active1.fields["sex"] = "Female"
							else
								active1.fields["sex"] = "Male"
					if("age")
						if (istype(active1, /datum/data/record))
							var/t1 = input("Please input age:", "Secure. records", active1.fields["age"], null)  as num
							if ((!( t1 ) || !( authenticated ) || usr.stat || usr.is_mob_restrained() || (!in_range(src, usr) && (!isRemoteControlling(usr))) || active1 != a1))
								return
							active1.fields["age"] = t1
					if("rank")
						//This was so silly before the change. Now it actually works without beating your head against the keyboard. /N
						if(istype(active1, /datum/data/record) && GLOB.highcom_paygrades.Find(rank))
							temp = "<h5>Occupation:</h5>"
							temp += "<ul>"
							for(var/rank in GLOB.joblist)
								temp += "<li><a href='?src=\ref[src];choice=Change Occupation;rank=[rank]'>[rank]</a></li>"
							temp += "</ul>"
						else
							alert(usr, "You do not have the required rank to do this!")
					if("species")
						if (istype(active1, /datum/data/record))
							var/t1 = copytext(trim(sanitize(input("Please enter race:", "General records", active1.fields["species"], null)  as message)),1,MAX_MESSAGE_LEN)
							if ((!( t1 ) || !( authenticated ) || usr.stat || usr.is_mob_restrained() || (!in_range(src, usr) && (!isRemoteControlling(usr))) || active1 != a1))
								return
							active1.fields["species"] = t1

//TEMPORARY MENU FUNCTIONS
			else//To properly clear as per clear screen.
				temp=null
				switch(href_list["choice"])
					if ("Change Rank")
						if (active1)
							active1.fields["rank"] = href_list["rank"]
							if(href_list["rank"] in GLOB.joblist)
								active1.fields["real_rank"] = href_list["real_rank"]

					if ("Delete Record (ALL) Execute")
						if (active1)
							for(var/datum/data/record/R as anything in GLOB.data_core.medical)
								if ((R.fields["name"] == active1.fields["name"] || R.fields["id"] == active1.fields["id"]))
									GLOB.data_core.medical -= R
									qdel(R)
							QDEL_NULL(active1)
					else
						temp = "This function does not appear to be working at the moment. Our apologies."

	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/structure/machinery/computer/skills/emp_act(severity)
	. = ..()
	if(inoperable())
		return

	for(var/datum/data/record/R in GLOB.data_core.security)
		if(prob(10/severity))
			switch(rand(1,6))
				if(1)
					R.fields["name"] = "[pick(pick(GLOB.first_names_male), pick(GLOB.first_names_female))] [pick(GLOB.last_names)]"
				if(2)
					R.fields["sex"] = pick("Male", "Female")
				if(3)
					R.fields["age"] = rand(5, 85)
				if(4)
					R.fields["criminal"] = pick("None", "*Arrest*", "Incarcerated", "Released")
				if(5)
					R.fields["p_stat"] = pick("*Unconcious*", "Active", "Physically Unfit")
				if(6)
					R.fields["m_stat"] = pick("*Insane*", "*Unstable*", "*Watch*", "Stable")
			continue

		else if(prob(1))
			GLOB.data_core.security -= R
			qdel(R)
			continue

