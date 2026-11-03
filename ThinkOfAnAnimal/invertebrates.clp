/*
** Jonny Tang
** November 3, 2026
** 
** Knowledge island for invertebrates. Batched from main.clp once the animal is not a vertebrate.
** 
** Experts (that played the Think of an Animal Game):
** Manan Gupta, Tanay Agrawal, Jaden Liu, Aaron Ma.
*/

(do-backward-chaining exoskeleton)
(do-backward-chaining venomous)
(do-backward-chaining tailStinger)
(do-backward-chaining mollusk)
(do-backward-chaining cnidarian)
(do-backward-chaining radialSymmetry)

/*
** Backward chaining need- rules
*/
(defrule need-exoskeleton "Asks if animal has an exoskeleton"
   (not (guessed))
   (need-exoskeleton ?)
=>
   (bind ?ans (assertYNU exoskeleton "Does the animal have an exoskeleton? "))
   (assert (exoskeletonFilter ?ans))
)

(defrule need-venomous "Asks if animal is venomous"
   (not (guessed))
   (need-venomous ?)
=>
   (bind ?ans (assertYNU venomous "Is the animal venomous? "))
   (assert (venomousFilter ?ans))
)

(defrule need-tailStinger "Asks if animal has a tail stinger"
   (not (guessed))
   (need-tailStinger ?)
=>
   (bind ?ans (assertYNU tailStinger "Does the animal have a stinger on its tail? "))
   (assert (tailStingerFilter ?ans))
)

(defrule need-mollusk "Asks if animal is a mollusk"
   (not (guessed))
   (need-mollusk ?)
=>
   (bind ?ans (assertYNU mollusk "Is the animal a mollusk? "))
   (assert (molluskFilter ?ans))
)

(defrule need-cnidarian "Asks if animal is a cnidarian"
   (not (guessed))
   (need-cnidarian ?)
=>
   (bind ?ans (assertYNU cnidarian "Is the animal a cnidarian? "))
   (assert (cnidarianFilter ?ans))
)

(defrule need-radialSymmetry "Asks if animal has radial symmetry"
   (not (guessed))
   (need-radialSymmetry ?)
=>
   (bind ?ans (assertYNU radialSymmetry "Does the animal have radial symmetry? "))
   (assert (radialSymmetryFilter ?ans))
)

/*
** Rules to guess the animals. Each rule has a string comment/description that describes the traits of 
** the said animal.
*/
(defrule isEarthworm "not vertebrate, no exoskeleton, not water animal"
   (not (guessed))
   (vertebrate n)
   (exoskeleton n)
   (waterAnimal n)
=>
   (guess "earthworm")
)

(defrule isSpider "not vertebrate, exoskeleton, not water animal, venomous, doesn't deliver venom through tail stinger"
   (not (guessed))
   (vertebrate n)
   (exoskeleton y)
   (waterAnimal n)
   (venomous y)
   (tailStinger n) ; not scorpion
=>
   (guess "spider")
)

(defrule isScorpion "not vertebrate, exoskeleton, not water animal, venomous, delivers venom through tail stinger"
   (not (guessed))
   (vertebrate n)
   (exoskeleton y)
   (waterAnimal n)
   (venomous y)
   (tailStinger y) ; not spider
=>
   (guess "scorpion")
)

(defrule isJellyfish "not vertebrate, no exoskeleton, water animal, cnidarian"
   (not (guessed))
   (vertebrate n)
   (exoskeleton n)
   (waterAnimal y)
   (cnidarian y)
=>
   (guess "jellyfish")
)

(defrule isOctopus "not vertebrate, no exoskeleton, water animal, mollusk"
   (not (guessed))
   (vertebrate n)
   (exoskeleton n)
   (waterAnimal y)
   (mollusk y)
=>
   (guess "octopus")
)

(defrule isCrab "not vertebrate, exoskeleton, water animal"
   (not (guessed))
   (vertebrate n)
   (exoskeleton y)
   (waterAnimal y)
=>
   (guess "crab")
)

(defrule isStarfish "not vertebate, no exoskeleton, water animal, radially symmetric"
   (not (guessed))
   (vertebrate n)
   (exoskeleton n)
   (waterAnimal y)
   (radialSymmetry y)
=>
   (guess "starfish")
)
