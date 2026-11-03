/*
** Jonny Tang
** November 3, 2026
** 
** Knowledge island for amphibians. Batched from main.clp once the animal is an amphibian.
** 
** Experts (that played the Think of an Animal Game):
** Manan Gupta, Tanay Agrawal, Jaden Liu, Aaron Ma.
*/

(defrule amphibianFilters "If amphibian, then filter these facts."
   (declare (salience ?*FILTER_SALIENCE*))
   (amphibianFilter y)
=>
   (assert (mammal n) (reptile n) (bird n) (fish n))
)

(defrule isFrog "amphibian"
   (not (guessed))
   (vertebrate y)
   (warmBlooded n)
   (amphibian y)  ; frog is the only amphibian
=>
   (guess "frog")
)
