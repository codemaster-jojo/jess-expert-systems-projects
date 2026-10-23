(clear)
(reset)

/*
** Dr. Eric R. Nelson
** April 2013
**
** This simple expert system assists the user in choosing the
** kinematics equation for constant acceleration based on
** what they are looking for and what they know. The 5
** variables are:
**
** acceleration, displacement, time, initial velocity
** and final velocity.
**
** Knowing any 3 of them allows you to solve for the
** other two, but the novice physics student can
** have difficulty figuring out which of the following
** 5 equations to use:
**
** 2 a ∆x = v^2 - v0^2
** ∆x = v0 t + 1/2 a t^2
** ∆x = v t - 1/2 a t^2
** ∆x = 1/2 (v + v0) t
** v = v0 + a t
**
** The program uses backward chaining to ask
** about the values of the 5 parameters. Now,
** it could stop at the first unknown value, because
** that is all you need to identify the correction equation, but
** novice uses often try to enter more than one unknown,
** so this program identifies the appropriate
** equation based on what is known, rather than
** what is unknown (which is how I would do it).
**
** When a solution is found, (solved) is
** asserted, which fires the alldone rule
** that shuts down the engine and ends the program.
**
** The program also illustrates the use of best practices in terms
** of reducing duplicated code elements in the input/output elements
** via the functions (askWhatIsThe) and (useEquation).
*/

(do-backward-chaining acceleration)
(do-backward-chaining time)
(do-backward-chaining displacement)
(do-backward-chaining velocity)
(do-backward-chaining initialvelocity)


/********************************
**
** Functions
**
*/
(deffunction ask (?a) "Get simple user input"
   (printout t ?a)    ; Print the user supplied prompt
   (return (read))    ; Read in a simple one word response
)

/*
** Outputs the commonly used prompt "What is the XXX?"
** where XXX is velocity, acceleration, displacement, etc.
*/
(deffunction askWhatIsThe (?a) "What is the XXX? "
   (bind ?v (str-cat "What is the " ?a "? "))
   (return (ask ?v))
)

/*
** Outputs the final message in the form
** crlf "use (some equation)" crlf crlf
*/
(deffunction useEquation (?a) "Nicely prints out the final message"
   (printout t crlf "use " ?a crlf crlf)
   (return)
)

/********************************
**
** Backward Chaining Rules
** Only ask for more information if
** the problem has not yet been
** solved.
**
*/
(defrule need-acc "Ask for the acceleration"
   (need-acceleration ?)
=>
   (bind ?x (askWhatIsThe "acceleration"))
   (assert (acceleration ?x))
)

(defrule need-interval "Ask for the time interval"
   (need-time ?)
=>
   (bind ?x (askWhatIsThe "time interval"))
   (assert (time ?x))
)

(defrule need-deltax "Ask for the displacement"
   (need-displacement ?)
=>
   (bind ?x (askWhatIsThe "displacement"))
   (assert (displacement ?x))
)

(defrule need-v "Ask for the velocity"
   (need-velocity ?)
=>
   (bind ?x (askWhatIsThe "final velocity"))
   (assert (velocity ?x))
)

(defrule need-v0 "Ask for the initial velocity"
   (need-initialvelocity ?)
=>
   (bind ?x (askWhatIsThe "initial velocity"))
   (assert (initialvelocity ?x))
)


/********************************
**
** Startup Rule (always fires first)
**
*/

(defrule startup
=> 
   (printout t crlf
               "Expert System that Helps in Simple Kinematics Problems:" crlf 
               "Only problems with constant acceleration can be addressed here." crlf
               "Enter unknown if you don't know a specific value." crlf crlf)

   (bind ?x (ask "What are you trying to find (a, x, v, v0, t)?"))

   (assert (lookingfor ?x))
)

/********************************
**
** Rule for using 2a ∆x = v^2 - v0^2
**
**/
(defrule equ-1 "2a ∆x = v^2 - v0^2"
   (or (and (lookingfor a)  (displacement ?x &~unknown) (velocity ?v &~unknown) (initialvelocity ?v0 &~unknown)                            )
       (and (lookingfor v0) (displacement ?x &~unknown) (velocity ?v &~unknown)                                 (acceleration ?a &~unknown))
       (and (lookingfor v)  (displacement ?x &~unknown)                         (initialvelocity ?v0 &~unknown) (acceleration ?a &~unknown))
       (and (lookingfor x)                              (velocity ?v &~unknown) (initialvelocity ?v0 &~unknown) (acceleration ?a &~unknown)))
=>
   (assert (solved))
   (useEquation "2a ∆x = v^2 - v0^2")
)

/********************************
**
** Rule for using ∆x = v0 t + 1/2 a t^2
**
**/
(defrule equ-2 "∆x = v0 t + 1/2 a t^2"
   (or (and (lookingfor a)  (displacement ?x &~unknown) (time ?t &~unknown) (initialvelocity ?v0 &~unknown)                            )
       (and (lookingfor v0) (displacement ?x &~unknown) (time ?t &~unknown)                                 (acceleration ?a &~unknown))
       (and (lookingfor t)  (displacement ?x &~unknown)                     (initialvelocity ?v0 &~unknown) (acceleration ?a &~unknown))
       (and (lookingfor x)                              (time ?t &~unknown) (initialvelocity ?v0 &~unknown) (acceleration ?a &~unknown)))
=>
   (assert (solved))
   (useEquation "∆x = v0 t + 1/2 a t^2")
)

/********************************
**
** Rule for using ∆x = v t - 1/2 a t^2
**
**/
(defrule equ-3 "∆x = v t - 1/2 a t^2"
   (or (and (lookingfor a) (displacement ?x &~unknown) (time ?t &~unknown) (velocity ?v &~unknown)                            )
       (and (lookingfor v) (displacement ?x &~unknown) (time ?t &~unknown)                         (acceleration ?a &~unknown))
       (and (lookingfor t) (displacement ?x &~unknown)                     (velocity ?v &~unknown) (acceleration ?a &~unknown))
       (and (lookingfor x)                             (time ?t &~unknown) (velocity ?v &~unknown) (acceleration ?a &~unknown)))
=>
   (assert (solved))
   (useEquation "∆x = v t - 1/2 a t^2")
)

/********************************
**
** Rule for using ∆x = 1/2 (v + v0) t
**
**/
(defrule equ-4 "∆x = 1/2 (v + v0) t"
   (or (and (lookingfor v0) (displacement ?x &~unknown) (time ?t &~unknown) (velocity ?v &~unknown)                                )
       (and (lookingfor v)  (displacement ?x &~unknown) (time ?t &~unknown)                         (initialvelocity ?v0 &~unknown))
       (and (lookingfor t)  (displacement ?x &~unknown)                     (velocity ?v &~unknown) (initialvelocity ?v0 &~unknown))
       (and (lookingfor x)                              (time ?t &~unknown) (velocity ?v &~unknown) (initialvelocity ?v0 &~unknown)))
=>
   (assert (solved))
   (useEquation "∆x = 1/2 (v + v0) t")
)

/********************************
**
** Rule for using v = v0 + a t
**
**/
(defrule equ-5 "v = v0 + a t"
   (or (and (lookingfor v0) (acceleration ?a &~unknown) (time ?t &~unknown) (velocity ?v &~unknown)                                )
       (and (lookingfor v)  (acceleration ?a &~unknown) (time ?t &~unknown)                         (initialvelocity ?v0 &~unknown))
       (and (lookingfor t)  (acceleration ?a &~unknown)                     (velocity ?v &~unknown) (initialvelocity ?v0 &~unknown))
       (and (lookingfor a)                              (time ?t &~unknown) (velocity ?v &~unknown) (initialvelocity ?v0 &~unknown)))
=>
   (assert (solved))
   (useEquation "v = v0 + a t")
)

/********************************
**
** Rule to capture no solution.
** This rule will go onto the agenda immediately, but
** because the salience level is so low, it will
** just sit there until there are no rules left to
** fire. Only then will it be examined, at which point
** if we have not solved the problem then we are
** missing some information.
**
**/
(defrule no-solution "The user has more than one unknown parameter"
   (declare (salience -100))
   (not (solved))
=>
   (printout t crlf "You need to specify at least three known values for a solution." crlf
               "Enter (reset)(run) at the prompt to try again." crlf crlf)
)

/********************************
**
** Rule to capture when a solution has been found.
** When solved is asserted this rule will be first in line to fire.
** It then shuts down the rule engine which stops any other rules from
** firing and ends the program.
**
**/
/
(defrule alldone "Rule that halts the program when a solution is found"
   (declare (salience 100))
   (solved)
=>
   (assert (solved)) ; Not really needed, but my OCD is kicking in here
   (halt)            ; The opposite of (run). This function shuts down the rule engine
)



(run)
