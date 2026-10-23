/*
** September 2, 2026
** Jonny Tang
** 
** This file contains methods intended to calculate fibonacci sequences.
** 
** Here is a list of all the methods in this file:
** fibo           - calculates and creates a list containing a fibonacci sequence iteratively
** isValid        - checks if input is valid (must be nonnegative integer)
** fibonacci      - validates input and then calls fibo, returns either FALSE or the list
** fib            - user interface, prompts user for input, prints either the sequence or
**                  an error message
*/

(batch utilities_v5.clp)

/*
** Calculates and returns a list of the fibonacci sequence of length ?num
** Input must be valid (nonnegative integer)
*/
(deffunction fibo (?num)
   (bind ?sequence (create$))
   (for (bind ?i 1) (<= ?i ?num) (++ ?i)
      (if (<= ?i 2) then                                                          ; base case: first and
         (bind ?sequence (insert$ ?sequence (+ 1 (length$ ?sequence)) 1))         ; second terms are 1
       else
         (bind ?nextVal (+ (nth$ (- ?i 1) ?sequence) (nth$ (- ?i 2) ?sequence)))  ; calculates the next term, and
         (bind ?sequence (insert$ ?sequence (+ 1 (length$ ?sequence)) ?nextVal))  ; then adds it to the list
      ) ; if (<= i 2) then
   ) ; for (bind ?i 0) (< ?i ?num) (++ ?i)

   (return ?sequence)
) ; (deffunction fibo (?num)

/*
** Checks if input is valid to calculate fibonacci. It must be a nonnegative number.
** Decimal points will be valid but later truncated.
*/
(deffunction isValid (?arg)
   (return (and (numberp ?arg) (>= ?arg 0)))
)

/*
** First validates the input, then either return false or the output of fibo
*/
(deffunction fibonacci (?num)
   (if (isValid ?num) then
      (bind ?output (fibo (integer ?num)))
    else
      (bind ?output FALSE)
   ) ; if (isValid ?num) then

   (return ?output)
)

/*
** User interface. Asks user for input number, then either prints that it's an invalid input
** or will print out the fibonacci sequence of that size.
*/
(deffunction fib ()
   (bind ?val (ask "Enter a nonnegative number representing the length of the fibonacci sequence to be generated: "))

   (bind ?result (fibonacci ?val))
   (if (listp ?result) then
      (print "The fibonacci sequence is: ")

      (for (bind ?i 1) (<= ?i (length$ ?result)) (++ ?i)  ; for loop to correctly format the list
         (print (nth$ ?i ?result) " ")                    ; ex. 1 1 2 3 instead of just 1123
      ) ; for (bind ?i 0) (< ?i (length$ ?result)) (++ ?i)

      (print crlf)
    else
      (print "Invalid input." crlf)
   ) ; if (listp ?result) then

   (return)
)