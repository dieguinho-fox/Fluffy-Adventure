local tutorialfuncional = {
	extends = Node,

	estado_anterior = nil
}

function tutorialfuncional:_process(delta)
	local root = self:get_tree():get_root()

	local keyboard = root:find_child("KeyboardTutorial", true, false)
	local playstation = root:find_child("PlaystationTutorial", true, false)
	local xbox360 = root:find_child("Xbox360Tutorial", true, false)
	local xboxone = root:find_child("XboxOneTutorial", true, false)
	local xboxseries = root:find_child("XboxSeriesTutorial", true, false)

	local atual = nil

	if keyboard and keyboard.visible then
		atual = "Teclado"
	elseif playstation and playstation.visible then
		atual = "PlayStation"
	elseif xbox360 and xbox360.visible then
		atual = "Xbox 360"
	elseif xboxone and xboxone.visible then
		atual = "Xbox One"
	elseif xboxseries and xboxseries.visible then
		atual = "Xbox Series"
	end

	-- só printa quando muda
	if atual ~= nil and atual ~= self.estado_anterior then
		print("[DEBUG] Tutorial carregado: " .. atual)
		self.estado_anterior = atual
	end
end

return tutorialfuncional
