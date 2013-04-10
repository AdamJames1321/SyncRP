--[[
Name: "sh_team.lua".
Product: "Cider (Roleplay)".
--]]

cider.team = {};
cider.team.index = 1;
cider.team.stored = {};

-- Add a new team.
function cider.team.add(name, color, males, females, description, salary, limit, access, blacklist)
	local data = {
		name = name,
		index = cider.team.index,
		color = color,
		models = {},
		salary = salary,
		limit = limit,
		access = access,
		blacklist = blacklist,
		description = description
	};
	
	-- Check if the male and female models are a table and if not make them one.
	if (males and type(males) != "table") then males = {males}; end;
	if (males and type(females) != "table") then females = {females}; end;
	
	-- Make the limit maximum players if there is none set.
	data.limit = data.limit or MaxPlayers();
	data.access = data.access or "b";
	data.description = data.description or "N/A.";
	data.models.male = males or cider.configuration["Male Citizen Models"];
	data.models.female = females or cider.configuration["Female Citizen Models"];
	
	-- Set the team up (this is called on the server and the client).
	team.SetUp(cider.team.index, name, color);
	
	-- Insert the data for our new team into our table.
	cider.team.stored[name] = data;
	
	-- Increase the team index so we don't duplicate any team.
	cider.team.index = cider.team.index + 1;
	
	-- Return the index of the team.
	return data.index;
end;

-- Get a team from a name of index.
function cider.team.get(name)
	local team;
	
	-- Check if we have a number (it's probably an index).
	if ( tonumber(name) ) then
		for k, v in pairs(cider.team.stored) do
			if ( v.index == tonumber(name) ) then team = v; break; end;
		end;
	else
		for k, v in pairs(cider.team.stored) do
			if ( string.find( string.lower(v.name), string.lower(name) ) ) then
				if (team) then
					if ( string.len(v.name) < string.len(team.name) ) then
						team = v;
					end;
				else
					team = v;
				end;
			end;
		end;
	end;
	
	-- Return the team that we found.
	return team;
end;

-- Check if the team has the required access.
function cider.team.hasAccess(name, access)
	local query = cider.team.query(name, "access")
	
	-- Check to see if the team has access.
	if (query) then
		if ( string.len(access) == 1 ) then
			return string.find(query, access)
		else
			for i = 1, string.len(access) do
				local flag = string.sub(access, i, i);
				
				-- Check to see if the team does not has this flag.
				if ( !cider.team.hasAccess(name, flag) ) then
					return false;
				end;
				
				-- Return true because we have all the required access.
				return true;
			end;
		end;
	else
		return false;
	end;
end;

-- Query a variable from a team.
function cider.team.query(name, key, default)
	local team = cider.team.get(name);
	
	-- Check to see if it's a valid team.
	if (team) then
		return team[key] or default;
	else
		return default;
	end;
end;

-- Check to see if we're running on the server.
if (SERVER) then
	function cider.team.blacklist(player, name, boolean)
		local team = cider.team.get(name);
		
		-- Check to see if the team exists.
		if (team) then
			if (boolean) then
				player.cider._Blacklist[team.name] = true;
			else
				player.cider._Blacklist[team.name] = nil;
			end;
		end;
	end;
	
	-- Make a player a member of a team.
	function cider.team.make(player, name)
		local team = cider.team.get(name);
		
		-- Check to see if the team exists.
		if (team) then
			if (!player.cider._Blacklist[team.name]) then
				player._NextChangeTeam[ player:Team() ] = CurTime() + 300;
				
				-- Set their new team and change their job.
				player:SetTeam(team.index);
				player._Job = team.name;
				
				-- Silently kill the player.
				player._ChangeTeam = true; player:KillSilent();
				
				-- Return true because it was successful.
				return true;
			else
				return false, "You have been blacklisted from "..team.name.."!";
			end;
		else
			return false, "This is not a valid team!";
		end;
	end;
end;