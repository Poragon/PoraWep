-- Variables

-- Coroutines

-- Functions

function monster_update_tick(monster)
	if DEBUG == true then 
		game.add_msg("Update called for: "..monster:get_name()) 
	end
	if monster:get_name() == "Beserker" then
		local monhp = monster:get_hp()
		local monhpmax = monster:get_hp_max()
		local hp_armor_multiplier = monhp / monhpmax 
		local beserker_armor_cut = 100
		local beserker_armor_bash = 50
		monster:set_armor_bash_bonus(beserker_armor_bash * hp_armor_multiplier)
		monster:set_armor_cut_bonus(beserker_armor_cut * hp_armor_multiplier)
	end
end

function echo_heal_1of10(monster)
	local ran = 2
	if ran == 2 then
		local monhpmax = monster:get_hp_max() 
		local monhp = monster:get_hp()
		local monhp_mod = monhpmax * 0.2
		if monhp + monhp_mod < monhpmax then
			monster:set_hp( monhp + monhp_mod )
		end
	end
end

function echo_speed_distortion(Creature)
	local ran = math.random(5)
	local dur = math.random(10,20)
	local dur_turns = TURNS(dur)
	if ran == 1 then
		Creature:add_effect(efftype_id("speed_distortion_terrible"), dur_turns)
	elseif ran == 2 then
		Creature:add_effect(efftype_id("speed_distortion_bad"), dur_turns)
	elseif ran == 3 then
		return
	elseif ran == 4 then
		Creature:add_effect(efftype_id("speed_distortion_good"), dur_turns)
	elseif ran == 5 then
		Creature:add_effect(efftype_id("speed_distortion_great"), dur_turns)
	end
end

function beserk_charge_attack(monster)
	local mon = game.get_critter_at(monster:pos())
	local beserker_rage = efftype_id("beserker_rage")
	local beserker_rage_duration = TURNS(7)
	if monster:sees(player) == true then
		game.add_msg("<color_red>The Breserker lets out a blood curling roar!</color>")
		monster:add_effect(beserker_rage, beserker_rage_duration)
	else
		return false
	end
end

function echo_random_attack(monster)
	if monster:sees(player) == true then 
		local attack = math.random(3)
		game.add_msg("The "..monster:get_name().."'s body vibrates and warps!")
		if DEBUG == true then
			game.add_msg("Echo Attack Number: "..attack)
		end
		if attack == 1 then
			local ran = math.random(10,20)
			local dur_turns = TURNS(ran)
			player:add_effect(efftype_id("deaf"), dur_turns)
			local pain_start = player:get_perceived_pain()
			local pain_mod = math.random(3,10)
			player:set_pain(pain_start + pain_mod)
			game.add_msg("<color_red>Vibrations rock through your body, paining your ears!</color>")
		elseif attack == 2 then
			echo_heal_1of10(monsters_around())
			game.add_msg("<color_red>A vile mist exudes from the echo, and mends the flesh of nearby foes!</color>")
		elseif attack == 3 then 
			echo_speed_distortion(monsters_around())
			echo_speed_distortion(player)
			game.add_msg("<color_magenta>The echo's distortions grow, distance and time seem warped!</color>")
		end
	end
end

function boomer_upgraded_attack(monster)
	local mon = monster
	if creature_distance_from_player(mon) < 3
	and monster:sees(player) == true then
		monster:set_moves(-100)
		local center = monster:pos()
		local off = 1
		for x = -off, off do
			for y = -off, off do
				local z = 0 
				if math.abs(x) == off or math.abs(y) == off then
					local point = tripoint(center.x + x, center.y + y, center.z + z) 
					local chance = math.random(3)
					if chance ~= 1 then
						local dur = math.random(15)
						local power = math.random(2)
						map:add_field(point, "fd_toxic_gas", power, TURNS(dur))
					end
				end
			end
		end
		if math.random(3) > 2 then
			player:add_effect(efftype_id("downed"), TURNS(3))
		else
			player:add_effect(efftype_id("stunned"), TURNS(3))
		end
		monster:die(player)
		game.add_msg("The "..monster:get_name().." explodes into a haze!")
	end
end	

function acid_boomer_attack(monster)
	local mon = monster
	if creature_distance_from_player(mon) < 3
	and monster:sees(player) == true then
		monster:set_moves(-100)
		local center = monster:pos()
		for off = 1, 2 do
			for x = -off, off do
				for y = -off, off do
					local z = 0 
					if math.abs(x) == off or math.abs(y) == off then
						local point = tripoint(center.x + x, center.y + y, center.z + z) 
						local chance = math.random(3)
						if chance == 1 then
							local dur = math.random(10, 30)
							local power = math.random(2)
							map:add_field(point, "fd_acid", power, TURNS(dur))
						end
					end
				end
			end
		end
		monster:die(player)
		game.add_msg("The "..monster:get_name().." explodes, flinging acid everywhere!")
	end
end	

function update_attack(monster)
	monster_update_tick(monsters_around())
	parasite_sense_danger(monsters_around())
end

-- Game Registers
game.register_monattack("BESERK_CHARGE", beserk_charge_attack)
game.register_monattack("ECHO_RANDOM", echo_random_attack)
game.register_monattack("UPDATE", update_attack)
game.register_monattack("BOOMER_UPGRADED", boomer_upgraded_attack )
game.register_monattack("ACID_BOOMER", acid_boomer_attack )