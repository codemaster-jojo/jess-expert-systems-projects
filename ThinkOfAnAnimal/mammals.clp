/*
** Jonny Tang
** November 3, 2026
** 
** Knowledge island for mammals. Batched from main.clp once the animal is a mammal.
** 
** Experts (that played the Think of an Animal Game):
** Manan Gupta, Tanay Agrawal, Jaden Liu, Aaron Ma.
*/

(do-backward-chaining livesInSaltwaterOcean)
(do-backward-chaining standOnTwoLimbs)
(do-backward-chaining apexPredator)
(do-backward-chaining buriesUnderground)
(do-backward-chaining trunk)
(do-backward-chaining longNeck)

/*
** Backward chaining need- rules for the mammal traits. Same structure as the main file.
*/
(defrule need-livesInSaltwaterOcean "Asks if animal lives in the ocean"
   (not (guessed))
   (need-livesInSaltwaterOcean ?)
=>
   (bind ?ans (assertYNU livesInSaltwaterOcean "Does the animal live in the ocean? "))
   (assert (livesInSaltwaterOceanFilter ?ans))
)

(defrule need-standOnTwoLimbs "Asks if animal can stand on two limbs"
   (not (guessed))
   (need-standOnTwoLimbs ?)
=>
   (bind ?ans (assertYNU standOnTwoLimbs "Does the animal usually stand on two limbs? "))
   (assert (standOnTwoLimbsFilter ?ans))
)

(defrule need-apexPredator "Asks if animal is apex predator"
   (not (guessed))
   (need-apexPredator ?)
=>
   (bind ?ans (assertYNU apexPredator "Is the animal an apex predator? "))
   (assert (apexPredatorFilter ?ans))
)

(defrule need-buriesUnderground "Asks if animal buries underground"
   (not (guessed))
   (need-buriesUnderground ?)
=>
   (bind ?ans (assertYNU buriesUnderground "Does the animal bury underground? "))
   (assert (buriesUndergroundFilter ?ans))
)

(defrule need-trunk "Asks if animal has a trunk"
   (not (guessed))
   (need-trunk ?)
=>
   (bind ?ans (assertYNU trunk "Does the animal have a trunk? "))
   (assert (trunkFilter ?ans))
)

(defrule need-longNeck "Asks if animal has a trunk"
   (not (guessed))
   (need-longNeck ?)
=>
   (bind ?ans (assertYNU longNeck "Does the animal have an exceptionally long neck? "))
   (assert (longNeckFilter ?ans))
)

/*
** Mammal filter rule. Mammal -> not any other type of animal.
*/
(defrule mammalFilters "If mammal, then filter these facts."
   (declare (salience ?*FILTER_SALIENCE*))
   (mammalFilter y)
=>
   (assert (reptile n) (amphibian n) (bird n) (fish n))
)

/*
** Mammal guessing rules. Each rule has a string description of its characteristics
*/
(defrule isBlueWhale "mammal, lives in water, lives in ocean"
   (not (guessed))
   (vertebrate y)
   (warmBlooded y)
   (mammal y)
   (waterAnimal y)
   (livesInSaltwaterOcean y) ; not platypus
=>
   (guess "blue whale")
)

(defrule isHuman "mammal, stands on 2 limbs, apex predator"
   (not (guessed))
   (vertebrate y)
   (warmBlooded y)
   (mammal y)
   (standOnTwoLimbs y)
   (apexPredator y) ; not kangaroo
=>
   (guess "human")
)

(defrule isKangaroo "mammal, stands on 2 limbs, not apex predator"
   (not (guessed))
   (vertebrate y)
   (warmBlooded y)
   (mammal y)
   (standOnTwoLimbs y)
   (apexPredator n) ; not human
=>
   (guess "kangaroo")
)

(defrule isRat "mammal, buries underground"
   (not (guessed))
   (vertebrate y)
   (warmBlooded y)
   (mammal y)
   (waterAnimal n)
   (buriesUnderground y)
=>
   (guess "rat")
)

(defrule isPlatypus "mammal, lives in water, doesn't live in saltwater"
   (not (guessed))
   (vertebrate y)
   (warmBlooded y)
   (mammal y)
   (waterAnimal y)
   (livesInSaltwaterOcean n) ; not whale
=>
   (guess "platypus")
)

(defrule isBat "mammal, can fly"
   (not (guessed))
   (vertebrate y)
   (warmBlooded y)
   (mammal y)
   (waterAnimal n)
   (fly y)
=>
   (guess "bat")
)

(defrule isElephant "mammal, has trunk"
   (not (guessed))
   (vertebrate y)
   (warmBlooded y)
   (mammal y)
   (waterAnimal n)
   (fly n)
   (trunk y)
=>
   (guess "elephant")
)

(defrule isGiraffe "mammal, has long neck"
   (not (guessed))
   (vertebrate y)
   (warmBlooded y)
   (mammal y)
   (waterAnimal n)
   (fly n)
   (longNeck y)
=>
   (guess "giraffe")
)
