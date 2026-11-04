/*
** October 19, 2026
** Jonny Tang
** 
** This is the main file for the Think of an Animal Expert System.
** 
** Required files:
** utilities_v5.clp
** mammals.clp          - batched once the animal is a mammal
** reptiles.clp         - batched once the animal is a reptile
** amphibians.clp       - batched once the animal is an amphibian
** birds.clp            - batched once the animal is a bird
** fish.clp             - batched once the animal is a fish
** invertebrates.clp    - batched once the animal is not a vertebrate
** 
** Experts (that played the Think of an Animal Game):
** Manan Gupta, Tanay Agrawal, Jaden Liu, Aaron Ma.
** 
** General algorithm approach:
** Use backward chaining to guess the animal and determine the questions needed to be asked.
** Use forward chaining as filters to avoid redundant questions (i.e. "is it a mammal?" -> yes.
** then, it won't ask if it is a reptile.)
** 
** This expert system is limited in that it is only able to guess out of a limited set of animals.
** Anything else would return an "I don't know" or a wrong guess.
** 
** Here are all of the functions in this file:
** assertYNU   - asks yes, no, or unknown. asserts the trait as y or n; unknown asserts both.
** guess       - guesses an animal. this is the terminating 
*/

(clear)
(reset)

(batch utilities_v5.clp)

(defglobal ?*FILTER_SALIENCE* = 100)
(defglobal ?*START_SALIENCE* = 10000)
(defglobal ?*UNSURE_SALIENCE* = -1000)

(defglobal ?*MAX_GUESSES* = 20)

(defglobal ?*num_guesses* = 0)


(do-backward-chaining vertebrate)
(do-backward-chaining warmBlooded)
(do-backward-chaining mammal)
(do-backward-chaining reptile)
(do-backward-chaining amphibian)
(do-backward-chaining bird)
(do-backward-chaining fish)
(do-backward-chaining waterAnimal)
(do-backward-chaining fly)
(do-backward-chaining omnivore)
(do-backward-chaining pets)
(do-backward-chaining activeDuringDay)

/*
** ================================================================================
** FUNCTIONS
** ================================================================================
*/

/*
** Asks a question and asserts the answer as a token on ?trait.
** y asserts (trait y). n asserts (trait n). u asserts both (trait y) and (trait n).
** Returns y, n, or u. Keeps asking until the input starts with one of those letters.
*/
(deffunction assertYNU (?trait ?question)
   (bind ?answer "")

   (if (>= ?*num_guesses* ?*MAX_GUESSES*) then
      (print "I have asked " ?*MAX_GUESSES* " questions and still do not know the animal. You win!" crlf)
      (halt)
      (bind ?answer u)
   else
      (bind ?*num_guesses* (+ 1 ?*num_guesses*))

      (while (not (member$ ?answer (create$ y n u)))         ; keep asking until they give a valid answer
         (print "Q" ?*num_guesses* ". ")
         (bind ?answer (sym-cat (sub-string 1 1 (lowcase (ask ?question))))) ; first character, as a token

         (if (not (member$ ?answer (create$ y n u))) then
            (printout t "Please enter a word that starts with y (yes), n (no), or u (unknown)." crlf)
         )
      ) ; while (not (member$ ?answer (create$ y n u)))

      (if (eq ?answer u) then
         (assert-string (str-cat "(" ?trait " y)"))
         (assert-string (str-cat "(" ?trait " n)"))
      else
         (assert-string (str-cat "(" ?trait " " ?answer ")"))
      )
   ) ; if (>= ?*num_guesses* ?*MAX_GUESSES*) then

   (return ?answer)
) ; deffunction assertYNU (?trait ?question)

/*
** Guesses the animal. This marks the end of the Think of an Animal game, right before the closing remarks
*/
(deffunction guess (?animal)
   (print "I am ready to guess! Here is my guess: " ?animal "." crlf)
   (bind ?ans (sym-cat (sub-string 1 1 (lowcase (ask "Am I correct (y/n)? "))))) ; first character, as a token
   (if (eq ?ans y) then
      (print "Nice! I win!" crlf)
   else
      (print "Aw, I'll get it next time... You won!" crlf)
   )
   (halt)
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
   (need-vertebrate ?)
=>
   (bind ?ans (assertYNU vertebrate "Is the animal a vertebrate? "))
   (assert (vertebrateFilter ?ans))
)

(defrule need-warmBlooded "Asks if animal is warm blooded"
   (need-warmBlooded ?)
=>
   (bind ?ans (assertYNU warmBlooded "Is the animal warm blooded? "))
   (assert (warmBloodedFilter ?ans))
)

(defrule need-mammal "Asks if animal is a mammal"
   (need-mammal ?)
=>
   (bind ?ans (assertYNU mammal "Is the animal a mammal? "))
   (assert (mammalFilter ?ans))
)

(defrule need-reptile "Asks if animal is a reptile"
   (need-reptile ?)
=>
   (bind ?ans (assertYNU reptile "Is the animal a reptile? "))
   (assert (reptileFilter ?ans))
)

(defrule need-amphibian "Asks if animal is an amphibian"
   (need-amphibian ?)
=>
   (bind ?ans (assertYNU amphibian "Is the animal an amphibian? "))
   (assert (amphibianFilter ?ans))
)

(defrule need-bird "Asks if animal is a bird"
   (need-bird ?)
=>
   (bind ?ans (assertYNU bird "Is the animal a bird? "))
   (assert (birdFilter ?ans))
)

(defrule need-fish "Asks if animal is a fish"
   (need-fish ?)
=>
   (bind ?ans (assertYNU fish "Is the animal a fish? "))
   (assert (fishFilter ?ans))
)

(defrule need-waterAnimal "Asks if animal lives in water"
   (need-waterAnimal ?)
=>
   (bind ?ans (assertYNU waterAnimal "Does the animal live in water? "))
   (assert (waterAnimalFilter ?ans))
)

(defrule need-fly "Asks if animal can fly"
   (need-fly ?)
=>
   (bind ?ans (assertYNU fly "Can the animal fly (not glide), even for short distances? "))
   (assert (flyFilter ?ans))
)

(defrule need-omnivore "Asks if animal is an omnivore"
   (need-omnivore ?)
=>
   (bind ?ans (assertYNU omnivore "Is the animal an omnivore? "))
   (assert (omnivoreFilter ?ans))
)

(defrule need-pets "Asks if animal is a pet"
   (need-pets ?)
=>
   (bind ?ans (assertYNU pets "Is the animal commonly kept as a pet? "))
   (assert (petsFilter ?ans))
)

(defrule need-activeDuringDay "Asks if animal is active during the day"
   (need-activeDuringDay ?)
=>
   (bind ?ans (assertYNU activeDuringDay "Is the animal active during the day? "))
   (assert (activeDuringDayFilter ?ans))
)

/*
** =================================================
** Filter rules, ex. if vertebrate then not cnidarian (etc.)
** These are forward chained.
*/

(defrule vertebrateFilters "If vertebrate, then filter these facts."
   (declare (salience ?*FILTER_SALIENCE*))
   (vertebrateFilter y)
=>
   (assert (exoskeleton n) (mollusk n) (cnidarian n))
)

(defrule notVertebrateFilters "If not vertebrate, then filter these facts."
   (declare (salience ?*FILTER_SALIENCE*))
   (vertebrateFilter n)
=>
   (assert (mammal n) (reptile n) (fish n) (bird n) (amphibian n))
)

(defrule warmBloodedFilter "If warm blooded, then filter these facts."
   (declare (salience ?*FILTER_SALIENCE*))
   (warmBloodedFilter y)
=>
   (assert (reptile n) (fish n) (amphibian n))
)

(defrule notWarmBloodedFilter "If not warm blooded, then filter these facts."
   (declare (salience ?*FILTER_SALIENCE*))
   (warmBloodedFilter n)
=>
   (assert (mammal n) (bird n))
)

/*
** =================================================
** Rules to guess the animal. Uses backward chaining!
*/
(defrule isMammal "batches the mammal knowledge island"
   (not (mammals-loaded))
   (vertebrate y)
   (warmBlooded y)
   (mammal y)
=>
   (assert (mammals-loaded))
   (batch mammals.clp)
)

(defrule isReptile "batches the reptile knowledge island"
   (not (reptiles-loaded))
   (vertebrate y)
   (warmBlooded n)
   (reptile y)
=>
   (assert (reptiles-loaded))
   (batch reptiles.clp)
)

(defrule isAmphibian "batches the amphibian knowledge island"
   (not (amphibians-loaded))
   (vertebrate y)
   (warmBlooded n)
   (amphibian y)
=>
   (assert (amphibians-loaded))
   (batch amphibians.clp)
)

(defrule isBird "batches the bird knowledge island"
   (not (birds-loaded))
   (vertebrate y)
   (warmBlooded y)
   (bird y)
=>
   (assert (birds-loaded))
   (batch birds.clp)
)

(defrule isFish "batches the fish knowledge island"
   (not (fish-loaded))
   (vertebrate y)
   (warmBlooded n)
   (fish y)
=>
   (assert (fish-loaded))
   (batch fish.clp)
)

(defrule isInvertebrate "batches the invertebrate knowledge island"
   (not (invertebrates-loaded))
   (vertebrate n)
=>
   (assert (invertebrates-loaded))
   (batch invertebrates.clp)
)

/*
** These rules are for the start/end of game, and also for when the expert system doesn't 
** know what the answer is.
*/
(defrule notSure "at the end, if the user doesn't know."
   (declare (salience ?*UNSURE_SALIENCE*))
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