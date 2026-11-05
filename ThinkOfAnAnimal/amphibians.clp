/*
** Jonny Tang
** November 3, 2026
** 
** Knowledge island for amphibians. Batched from main.clp once the animal is an amphibian.
** (vertebrate y)
** (warmBlooded n)
** (amphibian y)
** 
** Experts (that played the Think of an Animal Game):
** Manan Gupta, Tanay Agrawal, Jaden Liu, Aaron Ma.
*/

(do-backward-chaining tail)
(do-backward-chaining featheryGills)

/*
** Rules for backward chaining. These need- rules will fire when the trait is needed.
*/
(defrule need-tail "Asks if animal has a tail"
   (need-tail ?)
=>
   (bind ?ans (assertYNU tail "Does the animal have a tail in adulthood? "))
   (assert (tailFilter ?ans))
)

(defrule need-featheryGills "Asks if animal has feathery gills"
   (need-featheryGills ?)
=>
   (bind ?ans (assertYNU featheryGills "Does the animal have feathery gills? "))
   (assert (featheryGillsFilter ?ans))
)

/*
** Amphibian filter. ex. amphibian -> not reptile
*/
(defrule amphibianFilters "If amphibian, then filter these facts."
   (declare (salience ?*FILTER_SALIENCE*))
   (amphibianFilter y)
=>
   (assert (mammal n) (reptile n) (bird n) (fish n))
)

/*
** Rules to guess animals. These will end the game.
*/
(defrule isFrog "no tail"
   (tail n)
=>
   (guess "frog")
)

(defrule isAxolotl "tail, feathery gills"
   (tail y)
   (featheryGills y) ; not salamander
=>
   (guess "axolotl")
)

(defrule isSalamander "tail, no feathery gills"
   (tail y)
   (featheryGills n) ; not axolotl
=>
   (guess "salamander")
)