/*
** August 31, 2026
** Jonny Tang
** 
** This file contains a few methods intended to calculate factorials.
** The following lines provide a list of the methods and what each method does.
** 
** fact         - calculates the factorial using recursion
** isValid      - validates the input (must be nonnegative number, decimals get truncated)
** factorial    - adds user interface. asks user for input, validates, and calls fact
*/

(batch utilities_v5.clp)

/*
** Using recursion, calculates the factorial and returns it as a long
** Takes in a single long as an argument
*/
(deffunction fact (?value)
   (if (<= ?value 0) then                      ; base case: 0!=1
      (return 1)
    else 
      (return (* ?value (fact (- ?value 1))))  ; recursive case
   )
) ; deffunction fact (?value)

/*
** Validator to check if input for fact function is valid
** Must take in a nonnegative number.
*/
(deffunction isValid (?arg)
   (return (and (numberp ?arg) (>= ?arg 0)))
) ; deffunction isValid (?arg)

/*
** Main user interface. Asks the user for input, validates, and runs fact.
** If the input is invalid, the program will tell the user and will not run fact.
** If the user inputs a float, the program will truncate the number and
** get rid of the decimals.
*/
(deffunction factorial ()
   (bind ?val (ask "Enter a nonnegative integer to calculate the factorial of: "))

   (if (isValid ?val) then
      (printout t "The factorial is " (fact (long ?val)) "." crlf)
    else 
      (print "Invalid input." crlf)
   ) ; if (isValid (?val)) then
   
   (return)
) ; deffunction factorial ()