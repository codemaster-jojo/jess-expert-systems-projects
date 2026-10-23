/*
** September 15, 2026
** Jonny Tang
** 
** Anagrams 0 Project
** Simple project to learn more about the rule-based programming.
** Rules:
** anagram0 - gets all the permutations of 4 letters
** anagram1 - uses a template to get the permutations of 4 letters
*/

(batch utilities_v5.clp)

(clear)
(reset)

/*
** Template for Letters
*/
(deftemplate Letter (slot c) (slot p))

/*
** Will print out anagrams of the letters following the L in the pattern.
** i.e. A, A, C, and S (it works with duplicates.)
*/
(defrule anagram0
   (L ?c1 ?d1)
   (L ?c2 ?d2 & ~ ?d1)
   (L ?c3 ?d3 & ~ ?d1 & ~ ?d2)
   (L ?c4 ?d4 & ~ ?d1 & ~ ?d2 & ~ ?d3)
=>
   (printout t ?c1 ?c2 ?c3 ?c4 " ")
) ; defrule anagram0

/*
** Uses the Letter template to print out the anagrams of four letters.
*/
(defrule anagram1
   (Letter (c ?c1) (p ?p1))
   (Letter (c ?c2) (p ?p2 & ~ ?p1))
   (Letter (c ?c3) (p ?p3 & ~ ?p1 & ~ ?p2))
   (Letter (c ?c4) (p ?p4 & ~ ?p1 & ~ ?p2 & ~ ?p3))
=>
   (printout t ?c1 ?c2 ?c3 ?c4 " ")
) ; defrule anagram1

/*
** The first assertion works for anagram0, the second one works for anagram1
** Comment out the one that you don't want to fire.
*/
(assert (L A 1) (L T 2) (L C 3) (L S 4))
(assert (Letter (c A) (p 1)) (Letter (c T) (p 2)) (Letter (c C) (p 3)) (Letter (c S) (p 4)))