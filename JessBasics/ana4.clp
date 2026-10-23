/*
** September 30, 2026
** Jonny Tang
** 
** Anagrams 4
** This file uses dynamic rule creation to let the user choose any string of any length, instead
** of a fixed length.
** Here is a list of the rules in this file:
** main             - the main that will run everything when (run) is called.
** anagram4         - this rule will be dynamically created by (buildRule), and will list out anagrams.
** 
** Here is a list of all the functions in this file:
** buildRule        - builds the anagram4 rule dynamically, with the length of the anagrams built in
** slice$           - slices a string into its characters
** assertLetter     - accepts a letter and position with the letter template, asserts it
** assertLetters    - takes in a list of letters, asserts each letter with assertLetter
** validate         - makes sure a given input is short enough that JESS wouldn't crash.
** inputCharacters  - takes in a word, dynamically builds rule with buildRule, and then asserts 
**                    each letter
*/

(clear)
(reset)

(batch utilities_v5.clp)

/*
** Template for Letters
*/
(deftemplate Letter (slot c) (slot p))

/*
** Global constant defining a single space for buildRule
*/
(defglobal
   ?*SPACE* = "\" \""
)

/*
** Maximum anagram length that can run before JESS crashes.
*/
(defglobal 
   ?*MAX_LENGTH* = 11
)

/*
** User inputs a word of length 4, it will get validated and split to characters.
** Then its letters will be asserted.
*/
(defrule main "executes user input and sets up anagrams"
=>
   (inputCharacters)
) ; defrule main


/*
** Builds the anagram rule dynamically by creating a string defining the rule and calling
** the function build <string> on the string to turn it into a rule.
** LIMITATION: the rule built works for lengths less than 11. It isn't a limitation of building
** the function, but rather a limitation of the JESS engine, which will crash if asked to generate
** anagrams for a 11-length string.
*/
(deffunction buildRule (?length)
   (bind ?ruleDef "(defrule anagram4 ")
   (for (bind ?i 1) (<= ?i ?length) (++ ?i)                    ; builds each line on the LHS of the rule
      (bind ?expr (str-cat "(Letter (c ?c" ?i ") (p ?p" ?i))

      (for (bind ?j 1) (< ?j ?i) (++ ?j)                       ; builds the & ~ ?p1 & ~ ?p2 etc. on each line
         (bind ?expr (str-cat ?expr " & ~ ?p" ?j))
      ) ; for (bind ?j 1) (< ?j ?i) (++ ?j)

      (bind ?expr (str-cat ?expr "))"))
      (bind ?ruleDef (str-cat ?ruleDef ?expr " "))
   ) ; for (bind ?i 1) (<= ?i ?length) (++ i)
   (bind ?ruleDef (str-cat ?ruleDef "=>
   (printout t "))


   (for (bind ?i 1) (<= ?i ?length) (++ ?i)                    ; builds the RHS of the rule (the print statement)
      (bind ?ruleDef (str-cat ?ruleDef "?c" ?i " "))
   ) ; for (bind ?i 1) (<= ?i ?length) (++ ?i)
   (bind ?ruleDef (str-cat ?ruleDef ?*SPACE* "))"))

   (build ?ruleDef)

   (return)
) ; deffunction buildRule (?length)


/*
** Takes in a string and splits it into all the individual characters. Spaces remain.
** Returns the list of the individual characters
*/
(deffunction slice$ (?str)
   (bind ?chars (create$))

   (for (bind ?i 1) (<= ?i (str-length ?str)) (++ ?i)
      (bind ?chars (append$ ?chars (sub-string ?i ?i ?str)))
   ) ; for (bind ?i 1) (<= ?i (str-length ?str)) (++ ?i)

   (return ?chars)
) ; deffunction slice$ (?str)

/*
** Accepts a letter and position, uses letter template, asserts the letter and position
*/
(deffunction assertLetter (?c ?p)
   (assert (Letter (c ?c) (p ?p)))

   (return)
) ; deffunction assertLetter (?c ?p)

/*
** Accepts a list of letters, uses assertLetter to assert each letter with a different position.
*/
(deffunction assertLetters (?letters)
   (for (bind ?i 1) (<= ?i (length$ ?letters)) (++ ?i)
      (assertLetter (nth$ ?i ?letters) ?i)
   ) ; for (bind ?i 1) (<= ?i (length$ ?letters)) (++ ?i)

   (return)
) ; deffunction assertLetters (?letters)

/**
** Makes sure that the anagram isn't long enogh that it will crash JESS.
** Uses the global variable that defines max length.
*/
(deffunction validate (?length)
   (return (< ?length ?*MAX_LENGTH*))
) ; deffunction validate (?length)

/*
** Inputs characters from user, then validates and asserts it.
*/
(deffunction inputCharacters ()
   (bind ?letters (ask "Enter a word: "))
   (bind ?chars (slice$ ?letters))
   (bind ?length (str-length ?letters))

   (if (validate ?length) then
      (buildRule ?length)
      (assertLetters ?chars)
   else
      (print "Input is too long. Please choose a shorter phrase!")
   ) ; if (validate ?length) then
   

   (return)
) ; deffunction inputCharacters ()