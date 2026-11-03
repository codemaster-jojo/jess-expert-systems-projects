/*
** Jonny Tang
** November 3, 2026
** 
** Knowledge island for fish. Batched from main.clp once the animal is a fish.
** 
** Experts (that played the Think of an Animal Game):
** Manan Gupta, Tanay Agrawal, Jaden Liu, Aaron Ma.
*/

(do-backward-chaining canInflate)

/*
** Backward chaining need- rules.
*/
(defrule need-canInflate "Asks if animal can inflate"
   (not (guessed))
   (need-canInflate ?)
=>
   (bind ?ans (assertYNU canInflate "Can the animal inflate itself? "))
   (assert (canInflateFilter ?ans))
)

/*
** Forward chained filters (ex. if fish, then not mammal)
*/
(defrule fishFilters "If fish, then filter these facts."
   (declare (salience ?*FILTER_SALIENCE*))
   (fishFilter y)
=>
   (assert (mammal n) (reptile n) (amphibian n) (bird n))
)

/*
** Rules to guess the animals. Each rule has a string comment/description that describes the traits of 
** the said animal.
*/
(defrule isPufferfish "fish, can inflate"
   (not (guessed))
   (vertebrate y)
   (warmBlooded n)
   (fish y)
   (canInflate y) ; not eel
=>
   (guess "pufferfish")
)

(defrule isEel "fish, cannot inflate"
   (not (guessed))
   (vertebrate y)
   (warmBlooded n)
   (fish y)
   (canInflate n) ; not pufferfish
=>
   (guess "eel")
)
