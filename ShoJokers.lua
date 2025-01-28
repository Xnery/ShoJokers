SMODS.Atlas {
  key = "ShoJokers",
  path = "ShoJokers.png",
  px = 71,
  py = 95
}

SMODS.Joker {
  key = 'sho_armsfa',
  loc_txt = {
      name = 'Fuck You',
      text = {
          "{X:mult,C:white} X#1# {} Mult",
          "This card gives {C:gold}$1{}",
          "and is destroyed",
          "at end of round"
      }
  },
  no_pool_flag = 'sho_armsfa_extinct',
  config = { extra = { Xmult = 0 } },
  rarity = 1,
  atlas = 'ShoJokers',
  pos = { x = 0 , y = 0 },
  cost = 4,
  eternal_compat = false,
  loc_vars = function(self, info_queue, card)
      return { vars = { card.ability.extra.Xmult } }
  end,
  calculate = function(self, card, context)
      if context.joker_main then
          return {
              message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.Xmult } },
              Xmult_mod = card.ability.extra.Xmult
          }
      end
      if context.end_of_round and context.game_over == false and not context.repetition and not context.blueprint then
          G.E_MANAGER:add_event(Event({
              func = function()
                  play_sound('tarot1')
                  card.T.r = -0.2
                  card:juice_up(0.3, 0.4)
                  card.states.drag.is = true
                  card.children.center.pinch.x = true
                  G.E_MANAGER:add_event(Event({
                      trigger = 'after',
                      delay = 0.3,
                      blockable = false,
                      func = function()
                          G.jokers:remove_card(card)
                          card:remove()
                          card = nil
                          return true
                      end
                  }))
                  return true
              end
          }))
          G.GAME.pool_flags.sho_armsfa_extinct = true
          ease_dollars(1,true)
          return {
              message = 'Fuck you!',
          }
      end
  end
}

SMODS.Joker {
    key = 'sho_fresh',
    loc_txt = {
        name = 'Shofresh',
        text = {
            "{C:chips}+#1#{} Chips",
            "{C:green}#2# in #3#{} chance",
            "for this Joker to",
            "retrigger {C:attention}itself{}",
            "{C:inactive}(Up to 10 triggers){}",
        }
    },
    rarity = 2,
    atlas = 'ShoJokers',
    pos = { x = 1, y = 0 },
    config = { extra = { chips = 50, odds = 2, repetitions = 0, chipstotal = 50 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, (G.GAME.probabilities.normal or 1), card.ability.extra.odds, card.ability.extra.repetitions } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            card.ability.extra.repetitions = 0
            repeat
                card.ability.extra.repetitions = card.ability.extra.repetitions + 1
            until (card.ability.extra.repetitions >= 10) or (pseudorandom('sho_fresh') > G.GAME.probabilities.normal / card.ability.extra.odds)
            card.ability.extra.chipstotal = card.ability.extra.chips*card.ability.extra.repetitions
            return{
                message = localize { type = 'variable', key = 'a_chips', vars = { card.ability.extra.chipstotal } },
                chip_mod = card.ability.extra.chipstotal
            }
        end
    end
}

SMODS.Joker {
    key = 'sho_ciety',
    loc_txt = {
        name = 'Shociety',
        text = {
            "When {C:attention}Blind{} is selected",
            "sets money to {C:red}$0{}",
            "This Joker gains {C:white,X:mult}X0.05{}",
            "Mult per {C:gold}$1{} lost",
            "{C:inactive}(Currently {C:white,X:mult}X#2#{C:inactive} Mult){}"
        }
    },
    config = { extra = { Xmult = 1 } },
    rarity = 3,
    atlas = 'ShoJokers',
    pos = { x = 2 , y = 0 },
    cost = 6,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra, card.ability.extra.Xmult, G.GAME.dollars }}
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not self.getting_sliced and G.GAME.dollars > 0 then
            card.ability.extra.Xmult = G.GAME.dollars * 0.05 + card.ability.extra.Xmult
            ease_dollars(-G.GAME.dollars, true)
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.06*G.SETTINGS.GAMESPEED, blockable = false, blocking = false, func = function()
                play_sound('tarot2', 0.76, 0.4);return true end}))
            play_sound('tarot2', 1, 0.4)
            return {
                message = 'Upgraded!',
                colour = G.C.MULT,
                card = card
            }
        end
        if context.joker_main then
            return {
                message = localize { type = "variable", key = "a_xmult", vars = { card.ability.extra.Xmult } },
                Xmult_mod = card.ability.extra.Xmult,
            }
        end
    end
}

SMODS.Joker {
    key = 'sho_zonk',
    loc_txt = {
        name = 'Blunt Rotation',
        text = {
            "Chips required are",
            "reduced by {C:attention}#1#%{}"
        }
    },
    config = { extra = 15 },
    rarity = 2,
    atlas = 'ShoJokers',
    pos = { x = 3 , y = 0},
    cost = 6,
    loc_vars = function(self,info_queue,card)
        return { vars = { card.ability.extra, G.GAME.blind.chips, G.GAME.blind.chip_text } }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not self.getting_sliced then
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                play_sound('timpani')
                G.GAME.blind.chips = G.GAME.blind.chips * 0.85
                G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                return true end}))
            return{
                message = "Zonk!",
                color = G.C.GREEN,
                card = card
            }
        end
    end
}

SMODS.Joker {
    key = 'sho_suit',
    loc_txt = {
        name = 'Shourunner',
        text = {
            "{C:green}#1# in #2#{} chance",
            "to retrigger each",
            "{C:attention}played card{} up to",
            "{C:attention}2{} additional times"
        }
    },
    rarity = 2,
    atlas = 'ShoJokers',
    pos = { x = 4, y = 0 },
    config = { extra = { odds = 3, repetitions = 0 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { (G.GAME.probabilities.normal or 1), card.ability.extra.odds, card.ability.extra.repetitions } }
    end,
    calculate = function(self, card, context)
        if context.repetition then
            card.ability.extra.repetitions = 0
            while (card.ability.extra.repetitions < 2) and (pseudorandom('sho_suit') < G.GAME.probabilities.normal / card.ability.extra.odds) do
                card.ability.extra.repetitions = card.ability.extra.repetitions + 1
            end
            return {
                message = localize('k_again_ex'),
                repetitions = card.ability.extra.repetitions
            }
        end
    end
}