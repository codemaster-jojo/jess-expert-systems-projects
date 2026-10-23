/*
** October 10, 2026
** Jonny Tang
** 
** This is the main file for the mini Think of an Animal Expert System.
** 
** Here are all of the rules in this file:
** [list out all the rules]
** 
** Here are all of the functions in this file:
** askYNU      - asks yes, no, or unknown question. returns y, n, or u.
** guess       - guesses an animal. this is the terminating 
*/

(clear)
(reset)

(batch utilities_v5.clp)

(defglobal ?*EXCL_SALIENCE* = 100)
(defglobal ?*START_SALIENCE* = 10000)
(defglobal ?*UNSURE_SALIENCE* = -1000)
(defglobal ?*END_SALIENCE* = -10000)

/*
** ================================================================================
** FUNCTIONS
** ================================================================================
*/

/*
** This function asks a question and then return y, n, or u depending on if its yes, no, or unknown
** or if its y, n, or u. (for ease of dealing with in the rest of the )
** It will keep asking the same question until the user inputs something valid (a token that starts
** with y, n, or u).
*/
(deffunction askYNU (?question)
   (bind ?answer "")

   (while (not (member$ ?answer (create$ "y" "n" "u")))  ; keep asking until they give a valid answer
      (bind ?answer (sub-string 1 1 (lowcase (ask ?question))))

      (if (not (member$ ?answer (create$ "y" "n" "u"))) then
         (printout t "Please enter a word that starts with y (yes), n (no), or u (unknown)." crlf)
      )
   ) ; while (not (member$ ?answer (create$ "y" "n" "u")))

   (return ?answer)
) ; deffunction askYesNo (?question)

/*
** Guesses the animal. This marks the end of the Think of an Animal game, right before the closing remarks
*/
(deffunction guess (?animal)
   (assert (guessed))

   (print "I am ready to guess! I think the animal is a " ?animal "." crlf)
   (bind ?ans (lowcase (ask "Am I correct (y/n)? ")))
   (if (= ?ans "y") then
      (print "Nice!" crlf)
   else
      (print "Aw, I'll get it next time!" crlf)
   )
) ; deffunction guess (?animal)

/*
** ================================================================================
** RULES
** ================================================================================
*/

/*
** These rules will ask for a certain fact to be true or false. For example, it will ask
** "Is it a mammal?" or something along those lines. Most rules are self-explanatory by their
** rule name. If any clarification is necessary, it will be added in a preceding block comment.
** 
** These rules will utilize mandates and exclusions to manage the order of them firing. For example,
** the system will not ask "Is it a bird of prey" before knowing that it is a bird.
*/

/*
** First are rules to determine the group and classes of the animal.
** These are self-explanatory.
*/
(defrule isVertebrate "Ask if animal is a vertebrate"
   
=>
   (assert (vertebrate (askYNU "Is the animal a vertebrate? ")))
) ; defrule vertebrate "Ask if animal is a vertebrate"

(defrule isWarmBlooded "Ask if animal is warm blooded"
   (vertebrate "y")
=>
   (assert (warmBlooded (askYNU "Is the animal warm blooded? ")))
) ; defrule isWarmBlooded "Ask if animal is warm blooded"

(defrule isMammal "Ask if animal is mammal"
   (warmBlooded "y")
   (not (mammal ?))
=>
   (assert (mammal (askYNU "Is the animal a mammal? ")))
) ; defrule isMammal "Ask if animal is mammal"

(defrule isBird "Ask if animal is bird"
   (warmBlooded "y")
   (not (bird ?))
=>
   (assert (bird (askYNU "Is the animal a bird? ")))
) ; defrule isBird "Ask if animal is bird"

(defrule isReptile "Ask if animal is reptile"
   (vertebrate "y")
   (warmBlooded "n")
   (not (reptile ?))
=>
   (assert (reptile (askYNU "Is the animal a reptile? ")))
) ; defrule isReptile "Ask if animal is reptile"

(defrule isAmphibian "Ask if animal is amphibian"
   (vertebrate "y")
   (warmBlooded "n")
   (not (amphibian ?))
=>
   (assert (amphibian (askYNU "Is the animal an amphibian? ")))
) ; defrule isAmphibian "Ask if animal is amphibian"

(defrule isFish "Ask if animal is fish"
   (vertebrate "y")
   (warmBlooded "n")
   (not (fish ?))
=>
   (assert (fish (askYNU "Is the animal a fish? ")))
) ; defrule isFish "Ask if animal is fish"

/*
** Only necessary for blue whale, differentiate between blue whale and other mammals
*/
(defrule doesLiveInWater "Ask if animal lives in water"
   (mammal "y")
   (not (livesInWater ?))
=>
   (assert (livesInWater (askYNU "Does the animal live in water? ")))
) ; defrule doesLiveInWater "Ask if animal lives in water"

(defrule isBirdOfPrey "Ask if animal is bird of prey"
   (bird "y")
   (not (birdOfPrey ?))
=>
   (assert (birdOfPrey (askYNU "Is the animal a bird of prey? ")))
)

/*
** Separates ostrich from chicken
*/
(defrule isEaten "Ask if animal is commonly eaten by humans"
   (bird "y")
   (birdOfPrey "n")
   (not (eaten ?))
=>
   (assert (eaten (askYNU "Is the animal commonly eaten? ")))
)

/*
** These rules will set the mandates and exclusions (ex. if an animal is a mammal, it isn't
** a reptile). These have a higher salience value because they should run before the rules that
** ask for the traits.
*/

/*
** If an animal is of a certain class, it's not of the other classes.
** Ex. if it's a mammal it isn't a bird.
*/
(defrule mammalNotOthers "If mammal, set other classes to be no"
   (declare (salience ?*EXCL_SALIENCE*))
   (mammal "y")
=>
   (assert (bird "n") (reptile "n") (amphibian "n") (fish "n") (birdOfPrey "n"))
) ; defrule mammalNotOthers "If mammal, set other classes to be no"

(defrule birdNotOthers "If bird, set other classes to be no"
   (declare (salience ?*EXCL_SALIENCE*))
   (bird "y")
=>
   (assert (mammal "n") (reptile "n") (amphibian "n") (fish "n"))
) ; defrule birdNotOthers "If bird, set other classes to be no"

(defrule reptileNotOthers "If reptile, set other classes to be no"
   (declare (salience ?*EXCL_SALIENCE*))
   (reptile "y")
=>
   (assert (bird "n") (mammal "n") (amphibian "n") (fish "n") (birdOfPrey "n"))
) ; defrule reptileNotOthers "If reptile, set other classes to be no"

(defrule amphibianNotOthers "If amphibian, set other classes to be no"
   (declare (salience ?*EXCL_SALIENCE*))
   (amphibian "y")
=>
   (assert (bird "n") (reptile "n") (mammal "n") (fish "n") (birdOfPrey "n"))
) ; defrule mammalNotOthers "If amphibian, set other classes to be no"

(defrule fishNotOthers "If fish, set other classes to be no"
   (declare (salience ?*EXCL_SALIENCE*))
   (fish "y")
=>
   (assert (bird "n") (reptile "n") (amphibian "n") (mammal "n") (birdOfPrey "n") (livesInWater "y")
    (legs "n"))
) ; defrule mammalNotOthers "If fish, set other classes to be no"

/*
** Final rules to guess the animal
*/
(defrule isBlueWhale "Guesses blue whale"
   (mammal "y")
   (livesInWater "y")
=>
   (guess "blue whale")
)

(defrule isSnake "Guesses snake"
   (reptile "y")
=>
   (guess "snake")
)

(defrule isChicken "Guesses chicken"
   (bird "y")
   (birdOfPrey "n")
   (eaten "y")
=>
   (guess "chicken")
)

(defrule isOstrich "Guesses ostrich"
   (bird "y")
   (birdOfPrey "n")
   (eaten "n")
=>
   (guess "ostrich")
)

(defrule isOwl "Guesses owl"
   (bird "y")
   (birdOfPrey "y")
=>
   (guess "owl")
)

(defrule notSure "at the end, if the user doesn't know."
   (declare (salience ?*UNSURE_SALIENCE*))
   (not (guessed))
=>
   (print "I don't know what the animal is. " crlf)
)

(defrule startOfGame ""
   (declare (salience ?*START_SALIENCE*))
=>
   (print "Welcome to Think of an Animal. Think of an animal, and I will try to guess it. 
Answer with a token that starts with y, n, or u (for yes, no, and unknown, respectively). " crlf crlf)
)

(defrule endOfGame "Closing message before the program ends"
   (declare (salience ?*END_SALIENCE*))
=>
   (print "Thank you for playing the Think of an Animal game! See you later!" crlf)
)