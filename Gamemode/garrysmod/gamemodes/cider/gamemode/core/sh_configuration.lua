--[[
Name: "sh_configuration.lua".
Product: "Cider (Roleplay)".
--]]

cider.configuration["Default Money"] = 500; -- The money that each player starts with.
cider.configuration["Default Job"] = "Unemployed"; -- The job that each player starts with.
cider.configuration["Default Clan"] = ""; -- The clan that each player belongs to by default.
cider.configuration["Command Prefix"] = "/"; -- The prefix that is used for chat commands.
cider.configuration["Inventory Size"] = 30; -- The maximum inventory size.
cider.configuration["Salary Interval"] = 300; -- The interval that players receive their salary (seconds).
cider.configuration["Door Cost"] = 250; -- The money that it costs to purchase a door.
cider.configuration["Arrest Time"] = 600; -- The time that a player is arrested for (seconds).
cider.configuration["Contraband Interval"] = 120; -- The interval that players recieve money from their contraband (seconds).
cider.configuration["Local Voice"] = true; -- Players can only hear a player's voice if they are near them.
cider.configuration["Talk Radius"] = 256; -- The radius of each player that other players have to be in to hear them talk (units).
cider.configuration["Maximum Doors"] = 5; -- The maximum amount of doors a player can own.
cider.configuration["Maximum Notes"] = 10; -- The maximum amount of notes a player can write.
cider.configuration["Maximum Lockpick Uses"] = 1; -- The maximum amount of times a lockpick can be used.
cider.configuration["Cleanup Decals"] = true; -- Whether or not to automatically cleanup decals every minute.
cider.configuration["Advert Cost"] = 100; -- The money that it costs to advertise.
cider.configuration["Walk Speed"] = 250; -- The speed that players walk at.
cider.configuration["Run Speed"] = 375; -- The speed that players run at.
cider.configuration["Spawn Time"] = 30; -- The time that a player has to wait before they can spawn again (seconds).
cider.configuration["Bleed Time"] = 5; -- The time that a player bleeds for when they get damaged.
cider.configuration["Knock Out Time"] = 30; -- The time that a player gets knocked out for (seconds).
cider.configuration["Sleep Waiting Time"] = 5; -- The time that a player has to stand still for before they can fall asleep (seconds).
cider.configuration["Default Access"] = "b"; -- The access that each player begins with.
cider.configuration["Website URL"] = "http://kudomiku.com/forums/"; -- The website URL drawn at the bottom of the screen.
cider.configuration["Scale Ragdoll Damage"] = 2; -- How much to scale ragdolled player damage by.
cider.configuration["Scale Head Damage"] = 1; -- How much to scale head damage by.
cider.configuration["Scale Chest Damage"] = 0.75; -- How much to scale chest damage by.
cider.configuration["Scale Limb Damage"] = 0.5; -- How much to scale limb damage by.
cider.configuration["Search Warrant Expire Time"] = 60; -- The time that a player's search warrant expires (seconds) (set to 0 for never).
cider.configuration["Arrest Warrant Expire Time"] = 300; -- The time that a player's arrest warrant expires (seconds) (set to 0 for never).
cider.configuration["Default Inventory"] = {
	health_vial = 5,
	chinese = 5,
	beans = 5
}; -- The default inventory that each player starts with.
cider.configuration["Contraband"] = {
	cider_drug_lab = {maximum = 5, money = 50, name = "Drug Lab", health = 100, energy = 5},
	cider_money_printer = {maximum = 2, money = 150, name = "Money Printer", health = 100, energy = 5}
}; -- The different types of contraband.
cider.configuration["Male Citizen Models"] = {
	"models/player/Group01/male_01.mdl",
	"models/player/Group01/male_02.mdl",
	"models/player/Group01/male_03.mdl",
	"models/player/Group01/male_04.mdl",
	"models/player/Group01/male_05.mdl",
	"models/player/Group01/male_06.mdl",
	"models/player/Group01/male_07.mdl",
	"models/player/Group01/male_08.mdl",
	"models/player/Group01/male_09.mdl"
}; -- The male citizen models.
cider.configuration["Female Citizen Models"] = {
	"models/player/Group01/female_01.mdl",
	"models/player/Group01/female_02.mdl",
	"models/player/Group01/female_03.mdl",
	"models/player/Group01/female_04.mdl",
	"models/player/Group01/female_05.mdl",
	"models/player/Group01/female_06.mdl",
	"models/player/Group01/female_07.mdl"
}; -- The male citizen models.
cider.configuration["Banned Props"] = {
	"models/props_combine/combinetrain02b.mdl",
	"models/props_combine/combinetrain02a.mdl",
	"models/props_combine/combinetrain01.mdl",
	"models/cranes/crane_frame.mdl",
	"models/props_wasteland/cargo_container01.mdl",
	"models/props_c17/oildrum001_explosive.mdl",
	"models/props_canal/canal_bridge02.mdl",
	"models/props_canal/canal_bridge01.mdl",
	"models/props_canal/canal_bridge03a.mdl",
	"models/props_canal/canal_bridge03b.mdl",
	"models/props_wasteland/cargo_container01.mdl",
	"models/props_wasteland/cargo_container01c.mdl",
	"models/props_wasteland/cargo_container01b.mdl",
	"models/props_c17/column02a.mdl",
	"models/cranes/crane_frame.mdl",
	"models/props_c17/fence04a.mdl",
	"models/props_c17/fence03a.mdl",
	"models/props_c17/oildrum001_explosive.mdl",
	"models/props_combine/weaponstripper.mdl",
	"models/props_combine/combinetrain01a.mdl",
	"models/props_combine/combine_train02a.mdl",
	"models/props_combine/combine_train02b.mdl",
	"models/props_trainstation/train005.mdl",
	"models/props_trainstation/train004.mdl",
	"models/props_trainstation/train003.mdl",
	"models/props_trainstation/train001.mdl",
	"models/props_trainstation/train001.mdl",
	"models/props_wasteland/buoy01.mdl",
	"models/props/cs_militia/coveredbridge01_top.mdl",
	"models/props/cs_militia/coveredbridge01_left.mdl",
	"models/props/cs_militia/coveredbridge01_bottom.mdl",
	"models/props/cs_militia/silo_01.mdl",
	"models/props/cs_assault/money.mdl",
	"models/props/cs_assault/dollar.mdl",
	"models/props/de_nuke/ibeams_bombsitea.mdl",
	"models/props/de_nuke/fuel_cask.mdl",
	"models/props/de_nuke/ibeams_bombsitec.mdl",
	"models/props/de_nuke/ibeams_bombsite_d.mdl",
	"models/props/de_nuke/ibeams_ctspawna.mdl",
	"models/props/de_nuke/ibeams_ctspawnb.mdl",
	"models/props/de_nuke/ibeams_ctspawnc.mdl",
	"models/props/de_nuke/ibeams_tspawna.mdl",
	"models/props/de_nuke/ibeams_tspawnb.mdl",
	"models/props/de_nuke/ibeams_tunnela.mdl",
	"models/props/de_nuke/ibeams_tunnelb.mdl",
	"models/props/de_nuke/storagetank.mdl",
	"models/props/de_nuke/truck_nuke.mdl",
	"models/props/de_nuke/powerplanttank.mdl",
	"models/combine_helicopter.mdl",
	"models/props_trainstation/train002.mdl",
	"models/props_junk/gascan001a.mdl",
	"models/props_phx/mk-82.mdl",
	"models/props_phx/torpedo.mdl",
	"models/props_phx/misc/flakshell_big.mdl",
	"models/props_phx/playfield.mdl",
	"models/props_phx/amraam.mdl",
	"models/props_mining/techgate01_outland03.mdl",
	"models/props_mining/techgate01.mdl"
}; -- Props that are not allowed to be spawned.
cider.configuration["Rules"] = [[
1. No blocking with props.
2. No surfing with props.
3. No random deathmatching.
4. No climbing with props.
5. No random warranting.
6. No breaking NLR (New Life Rule).
7. When you become a team you must do what that team is for.
8. You may only be a hitman if you roleplay it properly.
9. No killing for revenge.
10. No racism or homophobia in OOC.
11. Do not use OOC for in-character discussion.
12. Do not use broadcast for OOC discussion.
13. No killing with props.
14. No pretending to be administrators.
15. No killing a player after you scam them.
16. No disconnecting from the server after you scam somebody.
17. Treat players how you would like to be treated.
18. There must be a way to get through your doors.
19. No punching without a valid reason.
20. Do not make anything porn related.
21. No using exploits. Report any that you find.
22. No building huge and useless shops.
23. No building a shop until you have enough money to sell items.
24. Do not disrespect administrators. They're here to help and to RP.
25. No killing black or white people because of their race.
26. No being a serial killer more than once a week.
27. You can only scam items if the team you're on doesn't sell them.
28. No deathmatching players for their weapons.
29. If you are being directly held hostage at gunpoint you must not
pull out a weapon and kill the hostage taker.
30. If you are being directly held hostage at gunpoint you must accept
any reasonable demands from the hostage taker.
31. If you are being held hostage you must eat food that the hostage
taker gives you.
32. If you are being held hostage you must not change classes or
disconnect from the server.
33. If you are being held hostage you must not go to sleep
unless the hostage taker permits it.
34. Do not kill somebody when they are typing unless they are
typing to avoid death.
35. If you are on the Combine team you cannot shoot players that
you have knocked out.
36. You do not automatically know the friends you have out-of-character
when you are in-character.
37. Do not complain if your contraband get raided or destroyed.
38. Remember that administrators are able to break any rule
whenever they wish.
39. You may have multiple doors to one entrance but there must be
enough distance between them to fit at least two players.
40. It must be possible to somehow get past every door that you have.
If the door is opened by a button, the button is not allowed to be
invisible.
41. If you are on the Combine team you must attempt to ask questions
before you shoot.
42. If you are on the Combine team and there is a hostage
situation, you must remember to first negotiate with the hostage taker.
43. The City Administrator is never allowed to make any of the available teams illegal.
44. The City Administrator is never allowed to make contraband legal, and must never
condone the use of contraband.
45. Cops are not supposed to kill during a lockdown. Try to knock out or
force Citizens back into their homes. Use killing as a last resort.
46. Do not kill a hostage after they have fulfilled your demands.
47. Do not carry out any threats that you made to a hostage after they
have fulfilled your demands.
48. These are not the only rules and ignorance is not an excuse.
At any point an administrator can declare a new rule. Make sure that you
are logical and you will not get banned.
49. If you are being held hostage you must not use the radio, or request
assistance unless the hostage taker permits it. In real life you would not
be able to reach your cell phone or radio as a hostage.
50. You can only use doors which came with the map or were created
with the Door STool. You may not create custom hydraulic doors or
anything similiar.
51. Do not create a clan unless you have at least 3 players ready to
join it.
52. Do not create a clan unless it has a forum thread explaining what
it is about, who is in it, and any upcoming events. Do not take the clan
feature lightly.
53. If you are caught using any exploits you will be permanently banned.
]]; -- The rules for the server.