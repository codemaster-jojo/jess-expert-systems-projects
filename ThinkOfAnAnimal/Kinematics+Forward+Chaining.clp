/*
** Forward Chaining Example
**
** Dr. Eric R. Nelson
** October 2, 2018
**
** Which of the 5 kinematics equations should I use for my problem?
**
** The 5 parameters are
**
** acceleration, displacement, time, initial velocity
** and final velocity.
**
** Knowing any 3 of them allows you to solve for the
** other two, but the novice physics student can
** have difficulty figuring out which of the following
** 5 equations to use:
**
** 2 a ∆x = v^2 - v0^2    : t
** ∆x = v0 t + 1/2 a t^2. : v
** ∆x = v t - 1/2 a t^2.  : v0
** ∆x = 1/2 (v + v0) t.   : a
** v = v0 + a t.          : ∆x
**
** We use (assert (dontCareAbout v)) for example to identify that we will use the second
** equation, so there will be 5 rules with a pattern similar to (dontCareAbout v) on the LHS
** of the rule which prints out the answer.
**
** The front end needs to ask something like "Do you know the value of X" where X is the
** parameter of interest. One question per parameter, but we only need three so we need
** to stop asking once we reach three Yes responses. We could use a global variable to
** keep track of the count and then use :(< ?*count* 3) in the rules, or we could use
** ?f<-(count ?x) & :(< ?count 3) for the pattern, retract the rule, then
** (assert (count (++ ?x)). Or we could have all the prompts have a simple LHS such as
** (not (done)) put ((assert (parm v)) in the RHS, for example and have a rule looks for three
** different parameters, just like the early anagram code.
*/


/*
** Ask what parameter are looking for. We now know what we have and what we want,
** which leaves what we don't want, which gets us the equation of interest.
*/

(deffunction ask (?prompt)
   (printout t ?prompt)
   (bind ?response (read))
   (return ?response)
)

(deffunction askQuestion (?prompt)
   (return (ask (str-cat ?prompt "? ")))
)

(deffunction askYesNo (?prompt)
   (bind ?result FALSE)
   (bind ?ans (sub-string 1 1 (upcase (ask ?prompt))))
   (if (= ?ans Y) then (bind ?result TRUE))
   (return ?result)
)

(deffunction askDoYouKnow (?parameter)
   (bind ?prompt (str-cat "Do you know the value of the " ?parameter "? "))
   (return (askYesNo ?prompt))
)

/*
** A short version of (printout t) that adds a crlf to the end. Accepts multiple arguments.
*/
(deffunction println ($?args)
   (foreach ?text $?args (printout t ?text))
   (printout t crlf)
   (return)
)

/*
* Helper functions
*/

/*
** Given three of the five, a, t, v, v0, x return a list of the remaining two
*/
(deffunction lastTwoParameters (?p1 ?p2 ?p3)
   (return (complement$ (create$ ?p1 ?p2 ?p3) (create$ a t v v0 x)))
)

/*
** Given a list and a single value, return what's in the list after that value is removed.
** This is used when there are only two items left in the list so the return value is a single item,
** but it works given a list of any length.
*/
(deffunction lastOne (?p ?list)
   (return (implode$ (complement$ (create$ ?p) ?list)))
)

/*
** Rules for asking if we know a specific parameter
*/
(defrule haveAcceleration "Ask about a"
   (not (gotThree))
=>
   (if (askDoYouKnow "acceleration") then (assert (parameter a)))
)

(defrule haveVelocity "Ask about v"
   (not (gotThree))
=>
   (if (askDoYouKnow "final velocity") then (assert (parameter v)))
)

(defrule haveInitialVelocity "Ask about v0"
   (not (gotThree))
=>
   (if (askDoYouKnow "initial velocity") then (assert (parameter v0))
))

(defrule haveTime "Ask about t"
   (not (gotThree))
=>
   (if (askDoYouKnow "time interval") then (assert (parameter t)))
)

(defrule haveDisplacement "Ask about ∆x"
   (not (gotThree))
=>
   (if (askDoYouKnow "displacement") then (assert (parameter x)))
)

/*
** Rule that looks to see if we have three of them and then asks
** what we are looking for. We need to test for the gotThree assertion
** because there are 6 patterns that will match the next line and we
** only want to respond on the first one.
*/
(defrule testForThree "Look for three different parameters just like an anagram"
   (not (gotThree))
   (parameter ?p1) (parameter ?p2 &~?p1) (parameter ?p3 &~?p1 &~?p2) 
=>
   (assert (gotThree))

   (println "You indicate you know the values of " ?p1 ", " ?p2 ", and " ?p3 ".")

   (bind ?lastTwo (lastTwoParameters ?p1 ?p2 ?p3))                      ; Given 3 of the 5, return a list of the remaining 2
   (printout t "You therefore can determine one of these two: " ?lastTwo crlf)

   (bind ?parm (askQuestion "What parameter are you seeking"))
   (bind ?dontCare (lastOne ?parm ?lastTwo))                            ; Given the remaining 2 and the one you want, return the one you don't care about

   (assert-string (str-cat "(dontCareAbout " ?dontCare ")"))            ; need to use assert-sting otherwise we get (dontCareAbout "a") for example
)


/*
** Rules to print out the final results based on the variable we don't care about
*/
(defrule useTimeEquation "Equation that is missing time"
   (dontCareAbout t)
=>
   (println "Use 2 a ∆x = v^2 - v0^2")
)

(defrule useVelocityEquation "Equation that is missing final velocity"
   (dontCareAbout v)
=>
   (println "Use ∆x = v0 t + 1/2 a t^2")
)

(defrule useInitialVelocityEquation "Equation that is missing initial velocity"
   (dontCareAbout v0)
=>
   (println "Use ∆x = v t - 1/2 a t^2")
)

(defrule useAccelerationEquation "Equation that is missing acceleration"
   (dontCareAbout a)
=>
   (println "Use ∆x = 1/2 (v + v0) t")
)

(defrule useDisplacementEquation "Equation that is missing displacement"
   (dontCareAbout x)
=>
   (println "Use v = v0 + a t")
)

(reset)	; needed to get the initial fact asserted
(run)
