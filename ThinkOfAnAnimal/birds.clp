/*
** Jonny Tang
** November 3, 2026
** 
** Knowledge island for birds. Batched from main.clp once the animal is known to be a bird.
** These facts are always asserted when this file is batched in:
** (vertebrate y)
** (warmBlooded y)
** (bird y)
** 
** Experts (that played the Think of an Animal Game):
** Manan Gupta, Tanay Agrawal, Jaden Liu, Aaron Ma.
*/

(do-backward-chaining repeatHumanWords)
(do-backward-chaining birdOfPrey)
(do-backward-chaining hovers)
(do-backward-chaining longNeck)
(do-backward-chaining waterfowl)

/*
** Backward chained need- rules. Self-explanatory.
*/
(defrule need-repeatHumanWords "Asks if animal repeats human words"
   (need-repeatHumanWords ?)
=>
   (bind ?ans (assertYNU repeatHumanWords "Can the animal repeat words that humans say? "))
   (assert (repeatHumanWordsFilter ?ans))
)

(defrule need-birdOfPrey "Asks if animal is a bird of prey"
   (need-birdOfPrey ?)
=>
   (bind ?ans (assertYNU birdOfPrey "Is the animal a bird of prey? "))
   (assert (birdOfPreyFilter ?ans))
)

(defrule need-hovers "Asks if animal hovers"
   (need-hovers ?)
=>
   (bind ?ans (assertYNU hovers "Does the animal hover? "))
   (assert (hoversFilter ?ans))
)

(defrule need-longNeck "Asks if animal has a long neck"
   (need-longNeck ?)
=>
   (bind ?ans (assertYNU longNeck "Does the animal have a long neck? "))
   (assert (longNeckFilter ?ans))
)

(defrule need-waterfowl "Asks if animal is a waterfowl"
   (need-waterfowl ?)
=>
   (bind ?ans (assertYNU waterfowl "Is the animal a waterfowl? "))
   (assert (waterfowlFilter ?ans))
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

(defrule notFlyFilter "If bird doesn't fly, then it doesn't hover"
   (declare (salience ?*FILTER_SALIENCE*))
   (flyFilter n)
=>
   (assert (hovers n))
)

(defrule hoverFilter "If bird hovers, then it flies"
   (declare (salience ?*FILTER_SALIENCE*))
   (hoversFilter y)
=>
   (assert (fly y))
)

/*
** Rules to guess the animals. Each rule has a string comment/description that describes the traits of 
** the said animal.
*/
(defrule isChicken "bird, flies, not bird of prey"
   (waterfowl n)
   (birdOfPrey n)
   (fly y)
   (repeatHumanWords n) ; not parrot
=>
   (guess "chicken")
)

(defrule isParrot "bird, flies, not bird of prey"
   (waterfowl n)
   (birdOfPrey n)
   (fly y)
   (repeatHumanWords y) ; not chicken
=>
   (guess "parrot")
)

(defrule isOstrich "bird, doesn't fly, not bird of prey"
   (waterfowl n)
   (fly n)
=>
   (guess "ostrich")
)

(defrule isOwl "bird, bird of prey"
   (waterfowl n)
   (birdOfPrey y)
=>
   (guess "owl")
)

(defrule isHummingbird "bird, hovers"
   (waterfowl n)
   (fly y)
   (hovers y)
=>
   (guess "hummingbird")
)

(defrule isSwan "bird, waterfowl, long neck"
   (waterfowl y)
   (longNeck y)
=>
   (guess "swan")
)

(defrule isDuck "bird, waterfowl, no long neck"
   (waterfowl y)
   (longNeck n) ; not swan
=>
   (guess "duck")
)