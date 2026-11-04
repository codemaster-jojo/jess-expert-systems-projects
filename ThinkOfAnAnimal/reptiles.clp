/*
** Jonny Tang
** November 3, 2026
** 
** Knowledge island for reptiles. Batched from main.clp once the animal is a reptile.
** 
** Experts (that played the Think of an Animal Game):
** Manan Gupta, Tanay Agrawal, Jaden Liu, Aaron Ma.
*/

(do-backward-chaining legs)
(do-backward-chaining canChangeColors)
(do-backward-chaining shell)
(do-backward-chaining livesInSaltwaterOcean)

/*
** Backward-chaining need- rules. Self explanatory.
*/
(defrule need-legs "Asks if animal has legs"
   (need-legs ?)
=>
   (bind ?ans (assertYNU legs "Does the animal have legs? "))
   (assert (legsFilter ?ans))
)

(defrule need-canChangeColors "Asks if animal can change colors"
   (need-canChangeColors ?)
=>
   (bind ?ans (assertYNU canChangeColors "Can the animal change colors? "))
   (assert (canChangeColorsFilter ?ans))
)

(defrule need-shell "Asks if animal has shell"
   (need-shell ?)
=>
   (bind ?ans (assertYNU shell "Does the animal have a shell? "))
   (assert (shellFilter ?ans))
)

(defrule need-livesInSaltwaterOcean "Ask if animal lives in saltwater"
   (need-livesInSaltwaterOcean ?)
=>
   (bind ?ans (assertYNU livesInSaltwaterOcean "Does the animal live in the ocean? "))
   (assert (livesInSaltwaterOceanFilter ?ans))
)

/*
** Forward chaining filters. Ex. if reptile, then not amphibian.
*/
(defrule reptileFilters "If reptile, then filter these facts."
   (declare (salience ?*FILTER_SALIENCE*))
   (reptileFilter y)
=>
   (assert (mammal n) (amphibian n) (bird n) (fish n))
)

/*
** Rules to guess the animals. Each rule has a string comment/description that describes the traits of 
** the said animal.
*/
(defrule isSnake "reptile, no legs"
   (legs n) ; not common lizard
=>
   (guess "snake")
)

(defrule isLizard "reptile, legs, cannot change color"
   (waterAnimal n)      ; not sea turtle or alligator
   (legs y)             ; not snake
   (canChangeColors n)  ; not chameleon
   (shell n)            ; not tortoise
=>
   (guess "common lizard")
)

(defrule isChameleon "reptile, legs, can change color"
   (waterAnimal n)
   (legs y)
   (canChangeColors y)
=>
   (guess "chameleon")
)

(defrule isTortoise "reptile, legs, shell"
   (waterAnimal n)
   (legs y)
   (shell y)
=>
   (guess "tortoise")
)

(defrule isSeaTurtle "reptile, water, saltwater"
   (waterAnimal y)
   (livesInSaltwaterOcean y)
=>
   (guess "sea turtle")
)

(defrule isAlligator "reptile, freshwater"
   (waterAnimal y)
   (livesInSaltwaterOcean n)
=>
   (guess "alligator")
)