/*
** September 22, 2026
** Jonny Tang
** 
** Anagrams 2 Project: Dynamic assertions
** Now the user will be able to enter their own anagram letters. The anagram length is fixed at 4.
** 
** Rules:
** anagram2             - responsible for printing out the anagrams of inputted letters
** main                 - main UI. user inputs a 4 letter token, letters are asserted
** 
** Functions:
** assertLetter         - accepts a letter and position with the letter template
** assertLetters        - takes in a list of letters, asserts each letter with assertLetter
** slice$                - takes in a string/token and splits it into a list of characters
** validate             - makes sure input is the right length (4 characters)
** inputCharacters      - validates parameters, and asserts.
*/

(clear)
(reset)

(batch utilities_v5.clp)

/*
** Template for Letters
*/
(deftemplate Letter (slot c) (slot p))

/*
** ==========================================================================================
** RULES
** ==========================================================================================
*/

/*
** Uses the Letter template to print out the anagrams of four letters.
*/
(defrule anagram2
   (Letter (c ?c1) (p ?p1))
   (Letter (c ?c2) (p ?p2 & ~ ?p1))
   (Letter (c ?c3) (p ?p3 & ~ ?p1 & ~ ?p2))
   (Letter (c ?c4) (p ?p4 & ~ ?p1 & ~ ?p2 & ~ ?p3))
=>
   (printout t ?c1 ?c2 ?c3 ?c4 " ")
) ; defrule anagram2

/*
** User inputs a word of length 4, it will get validated and split to characters.
** Then its letters will be asserted.
*/
(defrule main
=>
   (inputCharacters)
) ; defrule main

/*
** ==========================================================================================
** ANAGRAMS 2 FUNCTIONS
** ==========================================================================================
*/

/*
** Accepts a letter and position, uses letter template, asserts the letter and position
*/
(deffunction assertLetter (?c ?p)
   (assert (Letter (c ?c) (p ?p)))

   (return)
)

/*
** Accepts a list of letters, uses assertLetter to assert each letter with a different position.
** Fixed length of 4.
*/
(deffunction assertLetters (?letters)
   (for (bind ?i 1) (<= ?i 4) (++ ?i)       ; 4 for 4 letters, which is how long I chose my anagrams to be.
      (assertLetter (nth$ ?i ?letters) ?i)
   )

   (return)
)

/*
** ==========================================================================================
** ANAGRAMS 3 FUNCTIONS
** ==========================================================================================
*/

/*
** Takes in a string and splits it into all the individual characters. Spaces remain.
** Returns the list of the individual characters
*/
(deffunction slice$ (?str)
   (bind ?chars (create$))

   (for (bind ?i 1) (<= ?i (str-length ?str)) (++ ?i)
      (bind ?chars (append$ ?chars (sub-string ?i ?i ?str)))
   )

   (return ?chars)
) ; deffunction slice$ (?str)

/*
** Validates the string. Input must be of length 4. That is the only constraint.
*/
(deffunction validate (?chars)
   (return (= 4 (length$ ?chars)))
) ; deffunction validate (?chars)

/*
** Inputs characters from user, then validates and asserts it.
*/
(deffunction inputCharacters ()
   (bind ?letters (ask "Enter a four letter word: "))
   (bind ?chars (slice$ ?letters))

    (if (not (validate ?chars)) then
      (print "Invalid input. Must be length 4." crlf)
   else
      (assertLetters ?chars)
   )

   (return)
)