--[[
Name: "sv_chat.lua".
Product: "Cider (Roleplay)".
--]]

cider.chatBox = {};

-- Add a new line.
function cider.chatBox.add(recipientFilter, player, filter, text)
	if (player) then
		umsg.Start("cider.chatBox.playerMessage", recipientFilter);
			umsg.Entity(player);
			umsg.String(filter);
			umsg.String(text);
		umsg.End();
	else
		umsg.Start("cider.chatBox.message", recipientFilter);
			umsg.String(filter);
			umsg.String(text);
		umsg.End();
	end;
end;

-- Add a new line to players within the radius of a position.
function cider.chatBox.addInRadius(player, filter, text, position, radius)
	for k, v in pairs( g_Player.GetAll() ) do
		if (v:GetPos():Distance( position ) <= radius) then
			cider.chatBox.add(v, player, filter, text);
		end;
	end;
end;