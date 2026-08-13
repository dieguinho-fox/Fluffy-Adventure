extends Node

# Moedas e pontos
var coins := 0
var score := 0

# Onda atual
var wave := 1

# Quantos inimigos precisam ser derrotados nesta onda
var total_enemies := 0

# Quantos ainda faltam derrotar
var enemies_remaining := 0

# Quantos estão vivos na cena
var enemies_alive := 0

# ==========================================
# BATALHA FINAL
# ==========================================

var final_boss_phase: int = 1
var final_boss_hp: int = 10000
var final_boss_max_hp: int = 10000
