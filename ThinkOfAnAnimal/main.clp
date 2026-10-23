/*
** October 19, 2026
** Jonny Tang
** 
** This is the main file for the Think of an Animal Expert System.
** 
** Required files:
** utilities_v5.clp
** 
** Experts (that played the Think of an Animal Game):
** Manan Gupta, Tanay Agrawal, Jaden Liu, Aaron Ma.
** 
** General algorithm approach:
** Use backward chaining to guess the animal and determine the questions needed to be asked.
** Use forward chaining as filters to avoid redundant questions (i.e. "is it a mammal?" -> yes.
** then, it won't ask if it is a reptile.)
** 
** This expert system is limited in that it is only able to guess the following animals.
** Anything else would result in the expert system claiming they don't know which animal it is.
** Chicken
** Ostrich
** Owl
** Parrot
** Blue Whale
** Human
** Kangaroo
** Rat
** Platypus
** Bat
** Snake
** Common Lizard
** Chameleon
** Tortoise
** Frog
** Pufferfish
** Eel
** Earthworm
** Spider
** Scorpion
** Jellyfish
** Octopus
** Crab
** Starfish
** 
** Here are all of the functions in this file:
** askYNU      - asks yes, no, or unknown question. returns y, n, or u.
** guess       - guesses an animal. this is the terminating 
*/

(clear)
(reset)

(batch utilities_v5.clp)

(defglobal ?*FILTER_SALIENCE* = 100)
(defglobal ?*START_SALIENCE* = 10000)
(defglobal ?*UNSURE_SALIENCE* = -1000)
(defglobal ?*END_SALIENCE* = -10000)

(defglobal ?*MAX_GUESSES* = 20)

(defglobal ?*num_guesses* = 0)


(do-backward-chaining vertebrate)
(do-backward-chaining warmBlooded)
(do-backward-chaining exoskeleton)
(do-backward-chaining mammal)
(do-backward-chaining reptile)
(do-backward-chaining amphibian)
(do-backward-chaining bird)
(do-backward-chaining fish)
(do-backward-chaining canInflate)
(do-backward-chaining waterAnimal)
(do-backward-chaining venomous)
(do-backward-chaining tailStinger)
(do-backward-chaining mollusk)
(do-backward-chaining cnidarian)
(do-backward-chaining radialSymmetry)
(do-backward-chaining legs)
(do-backward-chaining canChangeColors)
(do-backward-chaining shell)
(do-backward-chaining livesInSaltwaterOcean)
(do-backward-chaining fly)
(do-backward-chaining repeatHumanWords)
(do-backward-chaining omnivore)
(do-backward-chaining apexPredator)
(do-backward-chaining birdOfPrey)
(do-backward-chaining buriesUnderground)
(do-backward-chaining standOnTwoLimbs)
(do-backward-chaining pets)
(do-backward-chaining activeDuringDay)

/*
** ================================================================================
** FUNCTIONS
** ================================================================================
*/

/*
** This function asks a question and then return y, n, or u depending on if its yes, no, or unknown
** or if its y, n, or u. (for standardization for the rest of the file.)
** It will keep asking the same question until the user inputs something valid (a token that starts
** with y, n, or u).
*/
(deffunction askYNU (?question)
   (bind ?answer "")

   (if (>= ?*num_guesses* ?*MAX_GUESSES*) then
      (print "I have asked " ?*MAX_GUESSES* " questions and still do not know the animal. You win!" crlf)
      (assert (guessed))
      (bind ?answer "u")
   else
      (bind ?*num_guesses* (+ 1 ?*num_guesses*))

      (while (not (member$ ?answer (create$ "y" "n" "u")))         ; keep asking until they give a valid answer
         (print "Q" ?*num_guesses* ". ")
         (bind ?answer (sub-string 1 1 (lowcase (ask ?question)))) ; gets the first character of the result

         (if (not (member$ ?answer (create$ "y" "n" "u"))) then
            (printout t "Please enter a word that starts with y (yes), n (no), or u (unknown)." crlf)
         )
      ) ; while (not (member$ ?answer (create$ "y" "n" "u")))
   )

   (return ?answer)
) ; deffunction askYesNo (?question)

/*
** Guesses the animal. This marks the end of the Think of an Animal game, right before the closing remarks
*/
(deffunction guess (?animal)
   (assert (guessed))

   (print "I am ready to guess! Here is my guess: " ?animal "." crlf)
   (bind ?ans (sub-string 1 1 (lowcase (ask "Am I correct (y/n)? ")))) ; gets the first character in lowercase
   (if (= ?ans "y") then
      (print "Nice! I win!" crlf)
   else
      (print "Aw, I'll get it next time... You won!" crlf)
   )
) ; deffunction guess (?animal)


/*
** ================================================================================
** RULES
** ================================================================================
*/

/*
** =================================================
** These rules handle the backward chaining.
*/

(defrule need-vertebrate "Asks if animal is a vertebrate"
   (not (guessed))
   (need-vertebrate ?)
=>
   (bind ?ans (askYNU "Is the animal a vertebrate? "))
   (assert (vertebrate ?ans))
   (assert (vertebrateFilter ?ans))
)

(defrule need-warmBlooded "Asks if animal is warm blooded"
   (not (guessed))
   (need-warmBlooded ?)
=>
   (bind ?ans (askYNU "Is the animal warm blooded? "))
   (assert (warmBlooded ?ans))
   (assert (warmBloodedFilter ?ans))
)

(defrule need-mammal "Asks if animal is a mammal"
   (not (guessed))
   (need-mammal ?)
=>
   (bind ?ans (askYNU "Is the animal a mammal? "))
   (assert (mammal ?ans))
   (assert (mammalFilter ?ans))
)

(defrule need-reptile "Asks if animal is a reptile"
   (not (guessed))
   (need-reptile ?)
=>
   (bind ?ans (askYNU "Is the animal a reptile? "))
   (assert (reptile ?ans))
   (assert (reptileFilter ?ans))
)

(defrule need-amphibian "Asks if animal is an amphibian"
   (not (guessed))
   (need-amphibian ?)
=>
   (bind ?ans (askYNU "Is the animal an amphibian? "))
   (assert (amphibian ?ans))
   (assert (amphibianFilter ?ans))
)

(defrule need-bird "Asks if animal is a bird"
   (not (guessed))
   (need-bird ?)
=>
   (bind ?ans (askYNU "Is the animal a bird? "))
   (assert (bird ?ans))
   (assert (birdFilter ?ans))
)

(defrule need-fish "Asks if animal is a fish"
   (not (guessed))
   (need-fish ?)
=>
   (bind ?ans (askYNU "Is the animal a fish? "))
   (assert (fish ?ans))
   (assert (fishFilter ?ans))
)

(defrule need-waterAnimal "Asks if animal lives in water"
   (not (guessed))
   (need-waterAnimal ?)
=>
   (bind ?ans (askYNU "Does the animal live in water? "))
   (assert (waterAnimal ?ans))
   (assert (waterAnimalFilter ?ans))
)

(defrule need-livesInSaltwaterOcean "Asks if animal lives in the ocean"
   (not (guessed))
   (need-livesInSaltwaterOcean ?)
=>
   (bind ?ans (askYNU "Does the animal live in the ocean? "))
   (assert (livesInSaltwaterOcean ?ans))
   (assert (livesInSaltwaterOceanFilter ?ans))
)

(defrule need-standOnTwoLimbs "Asks if animal can stand on two limbs"
   (not (guessed))
   (need-standOnTwoLimbs ?)
=>
   (bind ?ans (askYNU "Does the animal usually stand on two limbs? "))
   (assert (standOnTwoLimbs ?ans))
   (assert (standOnTwoLimbsFilter ?ans))
)

(defrule need-apexPredator "Asks if animal is apex predator"
   (not (guessed))
   (need-apexPredator ?)
=>
   (bind ?ans (askYNU "Is the animal an apex predator? "))
   (assert (apexPredator ?ans))
   (assert (apexPredatorFilter ?ans))
)

(defrule need-buriesUnderground "Asks if animal buries underground"
   (not (guessed))
   (need-buriesUnderground ?)
=>
   (bind ?ans (askYNU "Does the animal bury underground? "))
   (assert (buriesUnderground ?ans))
   (assert (buriesUndergroundFilter ?ans))
)

(defrule need-fly "Asks if animal can fly"
   (not (guessed))
   (need-fly ?)
=>
   (bind ?ans (askYNU "Can the animal fly (not glide), even for short distances? "))
   (assert (fly ?ans))
   (assert (flyFilter ?ans))
)

(defrule need-repeatHumanWords "Asks if animal repeats human words"
   (not (guessed))
   (need-repeatHumanWords ?)
=>
   (bind ?ans (askYNU "Can the animal repeat words that humans say? "))
   (assert (repeatHumanWords ?ans))
   (assert (repeatHumanWordsFilter ?ans))
)

(defrule need-legs "Asks if animal has legs"
   (not (guessed))
   (need-legs ?)
=>
   (bind ?ans (askYNU "Does the animal have legs? "))
   (assert (legs ?ans))
   (assert (legsFilter ?ans))
)

(defrule need-canChangeColors "Asks if animal can change colors"
   (not (guessed))
   (need-canChangeColors ?)
=>
   (bind ?ans (askYNU "Can the animal change colors? "))
   (assert (canChangeColors ?ans))
   (assert (canChangeColorsFilter ?ans))
)

(defrule need-shell "Asks if animal has shell"
   (not (guessed))
   (need-shell ?)
=>
   (bind ?ans (askYNU "Does the animal have a shell? "))
   (assert (shell ?ans))
   (assert (shellFilter ?ans))
)

(defrule need-exoskeleton "Asks if animal has an exoskeleton"
   (not (guessed))
   (need-exoskeleton ?)
=>
   (bind ?ans (askYNU "Does the animal have an exoskeleton? "))
   (assert (exoskeleton ?ans))
   (assert (exoskeletonFilter ?ans))
)

(defrule need-canInflate "Asks if animal can inflate"
   (not (guessed))
   (need-canInflate ?)
=>
   (bind ?ans (askYNU "Can the animal inflate itself? "))
   (assert (canInflate ?ans))
   (assert (canInflateFilter ?ans))
)

(defrule need-venomous "Asks if animal is venomous"
   (not (guessed))
   (need-venomous ?)
=>
   (bind ?ans (askYNU "Is the animal venomous? "))
   (assert (venomous ?ans))
   (assert (venomousFilter ?ans))
)

(defrule need-tailStinger "Asks if animal has a tail stinger"
   (not (guessed))
   (need-tailStinger ?)
=>
   (bind ?ans (askYNU "Does the animal have a stinger on its tail? "))
   (assert (tailStinger ?ans))
   (assert (tailStingerFilter ?ans))
)

(defrule need-mollusk "Asks if animal is a mollusk"
   (not (guessed))
   (need-mollusk ?)
=>
   (bind ?ans (askYNU "Is the animal a mollusk? "))
   (assert (mollusk ?ans))
   (assert (molluskFilter ?ans))
)

(defrule need-cnidarian "Asks if animal is a cnidarian"
   (not (guessed))
   (need-cnidarian ?)
=>
   (bind ?ans (askYNU "Is the animal a cnidarian? "))
   (assert (cnidarian ?ans))
   (assert (cnidarianFilter ?ans))
)

(defrule need-radialSymmetry "Asks if animal has radial symmetry"
   (not (guessed))
   (need-radialSymmetry ?)
=>
   (bind ?ans (askYNU "Does the animal have radial symmetry? "))
   (assert (radialSymmetry ?ans))
   (assert (radialSymmetryFilter ?ans))
)

(defrule need-omnivore "Asks if animal is an omnivore"
   (not (guessed))
   (need-omnivore ?)
=>
   (bind ?ans (askYNU "Is the animal an omnivore? "))
   (assert (omnivore ?ans))
   (assert (omnivoreFilter ?ans))
)

(defrule need-birdOfPrey "Asks if animal is a bird of prey"
   (not (guessed))
   (need-birdOfPrey ?)
=>
   (bind ?ans (askYNU "Is the animal a bird of prey? "))
   (assert (birdOfPrey ?ans))
   (assert (birdOfPreyFilter ?ans))
)

(defrule need-pets "Asks if animal is a pet"
   (not (guessed))
   (need-pets ?)
=>
   (bind ?ans (askYNU "Is the animal commonly kept as a pet? "))
   (assert (pets ?ans))
   (assert (petsFilter ?ans))
)

(defrule need-activeDuringDay "Asks if animal is active during the day"
   (not (guessed))
   (need-activeDuringDay ?)
=>
   (bind ?ans (askYNU "Is the animal active during the day? "))
   (assert (activeDuringDay ?ans))
   (assert (activeDuringDayFilter ?ans))
)

/*
** =================================================
** Filter rules, ex. if vertebrate then not cnidarian (etc.)
** These are forward chained.
*/

(defrule vertebrateFilters "If vertebrate, then filter these facts."
   (declare (salience ?*FILTER_SALIENCE*))
   (vertebrateFilter "y")
=>
   (assert (exoskeleton "n") (mollusk "n") (cnidarian "n"))
)

(defrule notVertebrateFilters "If not vertebrate, then filter these facts."
   (declare (salience ?*FILTER_SALIENCE*))
   (vertebrateFilter "n")
=>
   (assert (mammal "n") (reptile "n") (fish "n") (bird "n") (amphibian "n"))
)

(defrule warmBloodedFilter "If warm blooded, then filter these facts."
   (declare (salience ?*FILTER_SALIENCE*))
   (warmBloodedFilter "y")
=>
   (assert (reptile "n") (fish "n") (amphibian "n"))
)

(defrule notWarmBloodedFilter "If not warm blooded, then filter these facts."
   (declare (salience ?*FILTER_SALIENCE*))
   (warmBloodedFilter "n")
=>
   (assert (mammal "n") (bird "n"))
)

(defrule mammalFilters "If mammal, then filter these facts."
   (declare (salience ?*FILTER_SALIENCE*))
   (mammalFilter "y")
=>
   (assert (reptile "n") (amphibian "n") (bird "n") (fish "n"))
)

(defrule reptileFilters "If reptile, then filter these facts."
   (declare (salience ?*FILTER_SALIENCE*))
   (reptileFilter "y")
=>
   (assert (mammal "n") (amphibian "n") (bird "n") (fish "n"))
)

(defrule amphibianFilters "If amphibian, then filter these facts."
   (declare (salience ?*FILTER_SALIENCE*))
   (amphibianFilter "y")
=>
   (assert (mammal "n") (reptile "n") (bird "n") (fish "n"))
)

(defrule birdFilters "If bird, then filter these facts."
   (declare (salience ?*FILTER_SALIENCE*))
   (birdFilter "y")
=>
   (assert (mammal "n") (reptile "n") (amphibian "n") (fish "n"))
)

(defrule fishFilters "If bird, then filter these facts."
   (declare (salience ?*FILTER_SALIENCE*))
   (fishFilter "y")
=>
   (assert (mammal "n") (reptile "n") (amphibian "n") (bird "n"))
)

/*
** =================================================
** Rules to guess the animal. Uses backward chaining!
*/
(defrule isBlueWhale "mammal, lives in water, lives in ocean"
   (not (guessed))
   (vertebrate "y")
   (warmBlooded "y")
   (mammal "y")
   (waterAnimal "y")
   (livesInSaltwaterOcean "y") ; not platypus
=>
   (guess "blue whale")
)

(defrule isHuman "mammal, stands on 2 limbs, apex predator"
   (not (guessed))
   (vertebrate "y")
   (warmBlooded "y")
   (mammal "y")
   (standOnTwoLimbs "y")
   (apexPredator "y") ; not kangaroo
=>
   (guess "human")
)

(defrule isKangaroo "mammal, stands on 2 limbs, not apex predator"
   (not (guessed))
   (vertebrate "y")
   (warmBlooded "y")
   (mammal "y")
   (standOnTwoLimbs "y")
   (apexPredator "n") ; not human
=>
   (guess "kangaroo")
)

(defrule isRat "mammal, buries underground"
   (not (guessed))
   (vertebrate "y")
   (warmBlooded "y")
   (mammal "y")
   (waterAnimal "n")
   (buriesUnderground "y")
=>
   (guess "rat")
)

(defrule isPlatypus "mammal, lives in water, doesn't live in saltwater"
   (not (guessed))
   (vertebrate "y")
   (warmBlooded "y")
   (mammal "y")
   (waterAnimal "y")
   (livesInSaltwaterOcean "n") ; not whale
=>
   (guess "platypus")
)

(defrule isBat "mammal, can fly"
   (not (guessed))
   (vertebrate "y")
   (warmBlooded "y")
   (mammal "y")
   (waterAnimal "n")
   (fly "y")
=>
   (guess "bat")
)

(defrule isSnake "reptile, no legs"
   (not (guessed))
   (vertebrate "y")
   (warmBlooded "n")
   (reptile "y")
   (legs "n") ; not common lizard
=>
   (guess "snake")
)

(defrule isLizard "reptile, legs, cannot change color"
   (not (guessed))
   (vertebrate "y")
   (warmBlooded "n")
   (reptile "y")
   (legs "y")             ; not snake
   (canChangeColors "n")  ; not chameleon
   (shell "n")            ; not tortoise
=>
   (guess "common lizard")
)

(defrule isChameleon "reptile, legs, can change color"
   (not (guessed))
   (vertebrate "y")
   (warmBlooded "n")
   (reptile "y")
   (legs "y")             
   (canChangeColors "y")
=>
   (guess "chameleon")
)

(defrule isTortoise "reptile, legs, shell"
   (not (guessed))
   (vertebrate "y")
   (warmBlooded "n")
   (reptile "y")
   (legs "y")             
   (shell "y")
=>
   (guess "tortoise")
)

(defrule isChicken "bird, flies, not bird of prey"
   (not (guessed))
   (vertebrate "y")
   (warmBlooded "y")
   (bird "y")
   (birdOfPrey "n")
   (fly "y")
   (repeatHumanWords "n") ; not parrot
=>
   (guess "chicken")
)

(defrule isParrot "bird, flies, not bird of prey"
   (not (guessed))
   (vertebrate "y")
   (warmBlooded "y")
   (bird "y")
   (birdOfPrey "n")
   (fly "y")
   (repeatHumanWords "y") ; not chicken
=>
   (guess "parrot")
)


(defrule isOstrich "bird, doesn't fly, not bird of prey"
   (not (guessed))
   (vertebrate "y")
   (warmBlooded "y")
   (bird "y")
   (birdOfPrey "n")
   (fly "n")
=>
   (guess "ostrich")
)

(defrule isOwl "bird, bird of prey"
   (not (guessed))
   (vertebrate "y")
   (warmBlooded "y")
   (bird "y")
   (birdOfPrey "y")
=>
   (guess "owl")
)

(defrule isFrog "amphibian"
   (not (guessed))
   (vertebrate "y")
   (warmBlooded "n")
   (amphibian "y")  ; frog is the only amphibian
=>
   (guess "frog")
)

(defrule isPufferfish "fish, can inflate"
   (not (guessed))
   (vertebrate "y")
   (warmBlooded "n")
   (fish "y")
   (canInflate "y") ; not eel
=> 
   (guess "pufferfish")
)

(defrule isEel "fish, canot in flate"
   (not (guessed))
   (vertebrate "y")
   (warmBlooded "n")
   (fish "y")
   (canInflate "n") ; not pufferfish
=> 
   (guess "eel")
)

(defrule isEarthworm "not vertebrate, no exoskeleton, not water animal"
   (not (guessed))
   (vertebrate "n")
   (exoskeleton "n")
   (waterAnimal "n")
=>
   (guess "earthworm")
)


(defrule isSpider "not vertebrate, exoskeleton, not water animal, venomous, doesn't deliver venom through tail stinger"
   (not (guessed))
   (vertebrate "n")
   (exoskeleton "y")
   (waterAnimal "n")
   (venomous "y")
   (tailStinger "n") ; not scorpion
=>
   (guess "spider")
)

(defrule isScorpion "not vertebrate, exoskeleton, not water animal, venomous, delivers venom through tail stinger"
   (not (guessed))
   (vertebrate "n")
   (exoskeleton "y")
   (waterAnimal "n")
   (venomous "y")
   (tailStinger "y") ; not spider
=>
   (guess "scorpion")
)

(defrule isJellyfish "not vertebrate, no exoskeleton, water animal, cnidarian"
   (not (guessed))
   (vertebrate "n")
   (exoskeleton "n")
   (waterAnimal "y")
   (cnidarian "y")
=>
   (guess "jellyfish")
)

(defrule isOctopus "not vertebrate, no exoskeleton, water animal, mollusk"
   (not (guessed))
   (vertebrate "n")
   (exoskeleton "n")
   (waterAnimal "y")
   (mollusk "y")
=>
   (guess "octopus")
)

(defrule isCrab "not vertebrate, exoskeleton, water animal"
   (not (guessed))
   (vertebrate "n")
   (exoskeleton "y")
   (waterAnimal "y")
=>
   (guess "crab")
)

(defrule isStarfish "not vertebate, no exoskeleton, water animal, radially symmetric"
   (not (guessed))
   (vertebrate "n")
   (exoskeleton "n")
   (waterAnimal "y")
   (radialSymmetry "y")
=>
   (guess "starfish")
)

/*
** These rules are for the start/end of game, and also for when the expert system doesn't 
** know what the answer is.
*/
(defrule notSure "at the end, if the user doesn't know."
   (declare (salience ?*UNSURE_SALIENCE*))
   (not (guessed))
=>
   (print "I don't know what the animal is. " crlf)
)

(defrule startOfGame "Start of game before the system starts guessing"
   (declare (salience ?*START_SALIENCE*))
=>
   (print "Welcome to Think of an Animal. Think of an animal, and I will try to guess it. 
Answer with a token that starts with y, n, or u (for yes, no, and unknown, respectively).
I will have " ?*MAX_GUESSES* " questions to guess your animal. " crlf crlf)
)

(defrule endOfGame "Closing message before the program ends"
   (declare (salience ?*END_SALIENCE*))
=>
   (print crlf "Thank you for playing the Think of an Animal game! See you later!" crlf)
)