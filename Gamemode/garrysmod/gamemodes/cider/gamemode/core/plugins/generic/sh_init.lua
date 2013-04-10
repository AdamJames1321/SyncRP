--[[
Name: "sh_init.lua".
Product: "Cider (Roleplay)".
--]]

local PLUGIN = PLUGIN_SHARED;

-- Set some information for the plugin.
PLUGIN.name = "Generic";
PLUGIN.author = "Kudomiku";

-- A table of rebel models.
PLUGIN.rebelModels = {
	male = {
		"models/player/Group03/male_01.mdl",
		"models/player/Group03/male_02.mdl",
		"models/player/Group03/male_03.mdl",
		"models/player/Group03/male_04.mdl",
		"models/player/Group03/male_05.mdl",
		"models/player/Group03/male_06.mdl",
		"models/player/Group03/male_07.mdl",
		"models/player/Group03/male_08.mdl",
		"models/player/Group03/male_09.mdl"
	},
	female = {
		"models/player/Group03/female_01.mdl",
		"models/player/Group03/female_02.mdl",
		"models/player/Group03/female_03.mdl",
		"models/player/Group03/female_04.mdl",
		"models/player/Group03/female_05.mdl",
		"models/player/Group03/female_06.mdl",
		"models/player/Group03/female_07.mdl"
	}
};

-- Add the generic teams here.
-- TEAM_CITYADMINISTRATOR = cider.team.add("City Administrator", Color(255, 50, 25, 255), "models/player/breen.mdl", "models/player/mossman.mdl", "Runs the city and keeps it in shape.", 100, 1, nil, true);
-- TEAM_COMBINEOVERWATCH = cider.team.add("Combine Overwatch", Color(75, 150, 255, 255), "models/player/combine_super_soldier.mdl", "models/player/combine_super_soldier.mdl", "Controls the police and criminal justice.", 75, 1, nil, true);
-- TEAM_COMBINEOFFICER = cider.team.add("Combine Officer", Color(50, 50, 255, 255), "models/player/police.mdl", "models/player/police.mdl", "Maintains the city and arrests criminals.", 60, 10, nil, true);
-- TEAM_REBELLEADER = cider.team.add("Rebel Leader", Color(150, 150, 150, 255), "models/player/group03/male_03.mdl", "models/player/group03/female_07.mdl", "Controls the gangsters and organised crime.", 60, 1, nil, true);
-- TEAM_REBELDEALER = cider.team.add("Rebel Dealer", Color(125, 125, 125, 255), "models/player/group03/male_01.mdl", "models/player/group03/female_01.mdl", "Deals miscellaneous items to the city's inhabitants.", 50, 6, nil, true);
-- TEAM_REBEL = cider.team.add("Rebel", Color(100, 100, 100, 255), "models/player/group03/male_06.mdl", "models/player/group03/female_03.mdl", "A member of organised crime.", 45, 24, nil, true);
-- TEAM_PHARMACIST = cider.team.add("Pharmacist", Color(255, 200, 50, 255), "models/player/group01/male_06.mdl", "models/player/group01/female_07.mdl", "Deals pharmaceuticals to the city's inhabitants.", 55, 6, nil, true);
-- TEAM_ARMSDEALER = cider.team.add("Arms Dealer", Color(150, 25, 25, 255), "models/player/group01/male_05.mdl", "models/player/group01/female_06.mdl", "Deals weapons to the city's inhabitants.", 55, 6, nil, true);
-- TEAM_CITIZEN = cider.team.add("Citizen", Color(25, 150, 25, 255), "models/player/group01/male_04.mdl", "models/player/group01/female_02.mdl", "A regular Citizen living in the city.", 40);
-- TEAM_DOCTOR = cider.team.add("Doctor", Color(125, 225, 150, 255), "models/player/group01/male_03.mdl", "models/player/group01/female_03.mdl", "Deals medical supplies to the city's inhabitants.", 55, 6, nil, true);

TEAM_CITYADMINISTRATOR = cider.team.add("City Administrator", Color(255, 50, 25, 255), "models/player/breen.mdl", "models/player/mossman.mdl", "Runs the city and keeps it in shape.", 100, 1, nil, true);
TEAM_COMBINEOVERWATCH = cider.team.add("Combine Overwatch", Color(75, 150, 255, 255), "models/player/combine_super_soldier.mdl", "models/player/combine_super_soldier.mdl", "Controls the police and criminal justice.", 75, 1, nil, true);
TEAM_COMBINEOFFICER = cider.team.add("Combine Officer", Color(50, 50, 255, 255), "models/player/police.mdl", "models/player/police.mdl", "Maintains the city and arrests criminals.", 60, 10, nil, true);
TEAM_REBELLEADER = cider.team.add("Rebel Leader", Color(150, 150, 150, 255), PLUGIN.rebelModels.male, PLUGIN.rebelModels.female, "Controls the gangsters and organised crime.", 60, 1, nil, true);
TEAM_REBELDEALER = cider.team.add("Rebel Dealer", Color(125, 125, 125, 255), PLUGIN.rebelModels.male, PLUGIN.rebelModels.female, "Deals miscellaneous items to the city's inhabitants.", 50, 6, nil, true);
TEAM_REBEL = cider.team.add("Rebel", Color(100, 100, 100, 255), PLUGIN.rebelModels.male, PLUGIN.rebelModels.female, "A member of organised crime.", 45, 24, nil, true);
TEAM_PHARMACIST = cider.team.add("Pharmacist", Color(255, 200, 50, 255), nil, nil, "Deals pharmaceuticals to the city's inhabitants.", 55, 6, nil, true);
TEAM_ARMSDEALER = cider.team.add("Arms Dealer", Color(150, 25, 25, 255), nil, nil, "Deals weapons to the city's inhabitants.", 55, 6, nil, true);
TEAM_CITIZEN = cider.team.add("Citizen", Color(25, 150, 25, 255), nil, nil, "A regular Citizen living in the city.", 40);
TEAM_DOCTOR = cider.team.add("Doctor", Color(125, 225, 150, 255), nil, nil, "Deals medical supplies to the city's inhabitants.", 55, 6, nil, true);