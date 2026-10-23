/*
** September 9, 2026
** Jonny Tang
** 
** This file contains methods intended to output an alphabetical histogram from an ASCII paragraph
** (i.e., a histogram showing the frequencies of all the letters in the alphabet, case-insensitive)
** 
** The following lines provide a list of the methods in this file.
** slice$           - explodes string into a list of the individual characters
** increment$       - increments a certain index of a list by 1
** calcHisto        - calculates the alphabetical histogram and returns it
** histo            - user interface. asks user for input, then outputs the alphabetical histogram
*/

(batch utilities_v5.clp)

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
** Increments index of array by 1.
*/
(deffunction increment$ (?arr ?i)
   (return (replace$ ?arr ?i ?i (+ 1 (nth$ ?i ?arr))))
) ; deffunction increment$ (?arr ?i)

/*
** Calculates the histogram from a string and returns it, by first slicing it into its characters.
*/
(deffunction calcHisto (?para)
   (bind ?chars (slice$ ?para))
   (bind ?freq (create$))

   (for (bind ?j 1) (<= ?j 256) (++ ?j) ; initializes ?freq to 256 zeros, the size of the ASCII table.
      (bind ?freq (append$ ?freq 0))
   )

   (for (bind ?i 1) (<= ?i (length$ ?chars)) (++ ?i)     ; the index representing the char: 97 for a/A, etc.
      (bind ?char (nth$ ?i ?chars))                      ; 32 is 00100000 in binary, it will 
      (bind ?indexChar (bit-or (asc ?char) 32))          ; masks bit 6 to treat "a" and "A" the same. 
      (bind ?freq (increment$ ?freq ?indexChar))
   ) ; for (bind ?i 1) (<= ?i (length$ ?chars)) (++ ?i)

   (return ?freq)
) ; deffunction calcHisto (?para)

/*
** The input must be only ASCII characters from 0-255
** This is the main user interface. Asks user for a string, then calculates and prints out the histogram.
*/
(deffunction histo ()
   (bind ?paragraph (askline "Enter a paragraph of text: "))
   (bind ?freq (calcHisto ?paragraph))
    
   (print crlf "Here is the alphabetical histogram for your paragraph: " crlf)
   (for (bind ?i 97) (<= ?i 122) (++ ?i)                 ; 97 to 122 is the range of the alphabets A-Z
      (print (asciiToChar (- ?i 32)) ": " (nth$ ?i ?freq) crlf)
   )
   
   (return)
) ; deffunction histo ()