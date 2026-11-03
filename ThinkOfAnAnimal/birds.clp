/*
** Jonny Tang
** November 3, 2026
** 
** Knowledge island for birds. Batched from main.clp once the animal is a bird.
** 
** Experts (that played the Think of an Animal Game):
** Manan Gupta, Tanay Agrawal, Jaden Liu, Aaron Ma.
*/

(do-backward-chaining repeatHumanWords)
(do-backward-chaining birdOfPrey)

/*
** Backward chained need- rules. Self-explanatory.
*/
(defrule need-repeatHumanWords "Asks if animal repeats human words"
   (not (guessed))
   (need-repeatHumanWords ?)
=>
   (bind ?ans (assertYNU repeatHumanWords "Can the animal repeat words that humans say? "))
   (assert (repeatHumanWordsFilter ?ans))
)

(defrule need-birdOfPrey "Asks if animal is a bird of prey"
   (not (guessed))
   (need-birdOfPrey ?)
=>
   (bind ?ans (assertYNU birdOfPrey "Is the animal a bird of prey? "))
   (assert (birdOfPreyFilter ?ans))
)

/*
** Forward chained filters. i.e. if bird, then not mammal.
*/
(defrule birdFilters "If bird, then filter these facts."
   (declare (salience ?*FILTER_SALIENCE*))
   (birdFilter y)
=>
   (assert (mammal n) (reptile n) (amphibian n) (fish n))
)

/*
** Rules to guess the animals. Each rule has a string comment/description that describes the traits of 
** the said animal.
*/
(defrule isChicken "bird, flies, not bird of prey"
   (not (guessed))
   (vertebrate y)
   (warmBlooded y)
   (bird y)
   (birdOfPrey n)
   (fly y)
   (repeatHumanWords n) ; not parrot
=>
   (guess "chicken")
)

(defrule isParrot "bird, flies, not bird of prey"
   (not (guessed))
   (vertebrate y)
   (warmBlooded y)
   (bird y)
   (birdOfPrey n)
   (fly y)
   (repeatHumanWords y) ; not chicken
=>
   (guess "parrot")
)

(defrule isOstrich "bird, doesn't fly, not bird of prey"
   (not (guessed))
   (vertebrate y)
   (warmBlooded y)
   (bird y)
   (birdOfPrey n)
   (fly n)
=>
   (guess "ostrich")
)

(defrule isOwl "bird, bird of prey"
   (not (guessed))
   (vertebrate y)
   (warmBlooded y)
   (bird y)
   (birdOfPrey y)
=>
   (guess "owl")
)
