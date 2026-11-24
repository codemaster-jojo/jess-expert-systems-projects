/*
** November 9, 2026
** Jonny Tang
** 
** This is the main file for the Electronic Active Filter Expert System.
** 
** Required files:
** utilities_v5.clp
** CircuitGraphics.java (compiled, and on the Jess classpath)
** helpers.clp
** 
** Experts:
** Haiming Tang, EE masters and works in the industry for circuit and chip design.
** 
** General algorithm approach:
** The expert system uses both forward and backward chaining.
** Backward chaining is used as the primary reasoning method, determining which questions to ask the user.
** Then, forward chaining is used to supplement new facts from given facts to avoid asking redundant quesitons.
*/

(clear)
(reset)

(batch utilities_v5.clp)
(batch helpers.clp)

/*
** Salience values for (1) the initial rule that explains what the expert is, (2) the rule that fires
** when the expert system doesn't know what circuit to recommend, and (3 and 4) the width of the 
** schematic diagram.
*/
(defglobal ?*INITIAL_SALIENCE* = 1000)
(defglobal ?*UNSURE_SALIENCE* = -1000)
(defglobal ?*SCHEMATIC_WIDTH* = 400)
(defglobal ?*SCHEMATIC_HEIGHT* = 300)

/*
** E12 mantissas shared by the stocked resistors and capacitors.
** Resistor scales run from 10 ohms through 1 megohm (largest part 8.2 megohms).
** Capacitor scales run from 100 picofarads through 1 microfarad (largest part 8.2 microfarads).
** PREFERRED_RESISTOR breaks ties by favoring a value near 10 kilohms.
*/
(defglobal ?*E12_BASES* = (create$ 1.0 1.2 1.5 1.8 2.2 2.7 3.3 3.9 4.7 5.6 6.8 8.2))
(defglobal ?*RESISTOR_SCALES* = (create$ 10.0 100.0 1000.0 10000.0 100000.0 1000000.0))
(defglobal ?*CAPACITOR_SCALES* = (create$ 1.0e-10 1.0e-9 1.0e-8 1.0e-7 1.0e-6))
(defglobal ?*PREFERRED_RESISTOR* = 10000.0)
(defglobal ?*DECADE_SCALE* = 10.0)
(defglobal ?*SCHEMATIC_FRAME* = nil)

/*
** SI prefixes for displayed component values. Each prefix matches the exponent
** at the same position. ENGINEERING_DECIMALS is how many digits remain after
** the decimal point once the prefix is applied. SI_EXPONENT_STEP is the
** distance between those prefixes.
*/
(defglobal ?*SI_EXPONENTS* = (create$ 12 9 6 3 0 -3 -6 -9 -12 -15))
(defglobal ?*SI_PREFIXES* = (create$ "T" "G" "M" "k" "" "m" "μ" "n" "p" "f"))
(defglobal ?*ENGINEERING_DECIMALS* = 2)
(defglobal ?*SI_EXPONENT_STEP* = 3)

(import java.awt.image.BufferedImage)
(import javax.swing.ImageIcon)
(import javax.swing.JFrame)
(import javax.swing.JLabel)
(import CircuitGraphics)

(do-backward-chaining lowPass)
(do-backward-chaining approximationType)
(do-backward-chaining order)
(do-backward-chaining cutoff)
(do-backward-chaining r1)
(do-backward-chaining c1)
(do-backward-chaining gain)


/*
** =================================================
** INITIAL FACTS
** =================================================
*/
(deffacts E12 "Commonly found set of resistor and capacitor base values (E12)"
    (values ?*E12_BASES*) ; units: ohms or farads before a decade scale is applied
)

/*
** =================================================
** RULES
** =================================================
*/

/*
** These rules are the backward chaining rules. They determine the attributes necessary 
*/
(defrule need-lowPass "checks if user wants a low-pass filter"
   (need-lowPass ?)
=>
   (bind ?ans (askYNU "Do you want your active filter to attenuate high frequencies and keep low frequencies?"))
   (assert (lowPass ?ans))
)

(defrule need-approximationType "checks if user wants a butterworth filter"
   (need-approximationType ?)
=>
   (bind ?ans (askOptions "What filter approximation type do you want? 
   A. Butterworth
   B. Chebyshev
   C. Bessel
   D. I don't know
  " (create$ a b c d)))
   (if (= ?ans a) then 
      (assert (approximationType butterworth))
   )
   (if (= ?ans b) then
      (assert (approximationType chebyshev))
   )
   (if (= ?ans c) then
      (assert (approximationType bessel))
   ) 
   (if (= ?ans d) then
      (assert (tryApproximationsAgain))
   )
)

(defrule need-order "asks for the order or routes unknown answers to specification collection"
   (need-order ?)
=>
   (bind ?order (askNumber "Enter the filter order, or u if unknown:"))
   (if (eq ?order u) then
      (assert (needOrderCalculation))
   else
      (while (or (<= ?order 0) (neq ?order (round ?order)))
         (bind ?order (askNumber "Enter a positive whole-number order, or u if unknown:"))
         (if (eq ?order u) then
            (bind ?order 0)
         )
      ) ; while (or (<= ?order 0) (neq ?order (round ?order)))
      (if (> ?order 0) then
         (assert (order ?order))
      else
         (assert (needOrderCalculation))
      )
   ) ; if (eq ?order u) then
) ; defrule need-order "asks for the order or routes unknown answers to specification collection"

(defrule need-gain "asks for the gain"
   (need-gain ?)
=>
   (bind ?gain (askNumber "Enter the gain, or u if unknown:"))
   (assert (gain ?gain))
)

(defrule ask-orderSpecifications "collects the four values needed to calculate filter order"
   (needOrderCalculation)
=>
   (bind ?passbandAttenuation (askNumber "Maximum passband attenuation Ap (dB):"))
   (bind ?stopbandAttenuation (askNumber "Minimum stopband attenuation As (dB):"))
   (bind ?passbandEdge (askNumber "Passband edge frequency fp (Hz):"))
   (bind ?stopbandEdge (askNumber "Stopband edge frequency fs (Hz):"))

   (if (or (eq ?passbandAttenuation u) ; if any values are unknown, you cannot calculate filter order
           (eq ?stopbandAttenuation u) ; so it is asserted as unknown
           (eq ?passbandEdge u)
           (eq ?stopbandEdge u)) then
      (assert (order unknown))
   else
      (while (or (<= ?passbandAttenuation 0)
                 (<= ?stopbandAttenuation ?passbandAttenuation)
                 (<= ?passbandEdge 0)
                 (<= ?stopbandEdge ?passbandEdge))
         (print "Values must satisfy 0 < Ap < As and 0 < fp < fs for a low-pass filter." crlf)
         (bind ?passbandAttenuation (askNumber "Maximum passband attenuation Ap (dB):"))
         (bind ?stopbandAttenuation (askNumber "Minimum stopband attenuation As (dB):"))
         (bind ?passbandEdge (askNumber "Passband edge frequency fp (Hz):"))
         (bind ?stopbandEdge (askNumber "Stopband edge frequency fs (Hz):"))
      ) ; while (or (<= ?passbandAttenuation 0) ...

      (assert (passbandAttenuation ?passbandAttenuation))
      (assert (stopbandAttenuation ?stopbandAttenuation))
      (assert (passbandEdge ?passbandEdge))
      (assert (stopbandEdge ?stopbandEdge))
   ) ; if (or (eq ?passbandAttenuation u) ...
) ; defrule ask-orderSpecifications "collects the four values needed to calculate filter order"

(defrule calculate-filterOrder "derives the minimum order when all four specifications are known"
   (passbandAttenuation ?passbandAttenuation)
   (stopbandAttenuation ?stopbandAttenuation)
   (passbandEdge ?passbandEdge)
   (stopbandEdge ?stopbandEdge)
   (not (order ?))
=>
   (bind ?attenuationRatio
      (/ (- (** 10 (/ ?stopbandAttenuation 10.0)) 1.0)
         (- (** 10 (/ ?passbandAttenuation 10.0)) 1.0)))
   (bind ?frequencyRatio (/ ?stopbandEdge ?passbandEdge))
   (bind ?rawOrder
      (/ (log ?attenuationRatio)
         (* 2.0 (log ?frequencyRatio))))
   (bind ?minimumOrder (integer ?rawOrder))
   (if (< ?minimumOrder ?rawOrder) then
      (bind ?minimumOrder (+ ?minimumOrder 1))
   )
   (assert (order ?minimumOrder))
) ; defrule calculate-filterOrder

/*
** For a first-order Butterworth response, Ap at fp fixes the cutoff:
** fc = fp / sqrt(10^(Ap/10) - 1). Both specification facts must be positive,
** which the collection rule already enforces.
*/
(defrule need-cutoffFromSpecification "derives the first-order Butterworth cutoff from Ap and fp"
   (need-cutoff ?)
   (passbandAttenuation ?passbandAttenuation)
   (passbandEdge ?passbandEdge)
=>
   (bind ?attenuationRatio (- (** 10 (/ ?passbandAttenuation ?*DECADE_SCALE*)) 1.0))
   (bind ?fc (/ ?passbandEdge (sqrt ?attenuationRatio)))
   (printline "Cutoff frequency from the passband specification: " ?fc " Hz")
   (assert (cutoff ?fc))
) ; defrule need-cutoffFromSpecification "derives the first-order Butterworth cutoff from Ap and fp"

/*
** Asks for fc when the user gave the order directly and no passband edge exists.
*/
(defrule need-cutoffAsk "asks for the cutoff when no passband specification was given"
   (need-cutoff ?)
   (not (passbandEdge ?))
=>
   (bind ?fc (askNumber "Enter the cutoff frequency fc (Hz):"))
   (while (or (not (numberp ?fc)) (<= ?fc 0))
      (bind ?fc (askNumber "Enter a positive cutoff frequency fc (Hz):"))
   ) ; while (or (not (numberp ?fc)) (<= ?fc 0))
   (assert (cutoff ?fc))
) ; defrule need-cutoffAsk "asks for the cutoff when no passband specification was given"

/*
** The first-order recommendation needs a resistor. Ask once, after the cutoff
** is known. A numeric answer is stored as r1. u is recorded in resistorChoice
** so the capacitor rules can run while the r1 goal stays open.
*/
(defrule need-r1Ask "asks for a resistor once the first-order cutoff is known"
   (need-r1 ?)
   (cutoff ?fc)
   (not (resistorChoice ?))
=>
   (printout t "butterworth, low-pass, first-order filter." crlf)
   (printline "Choosing parts for a cutoff of " ?fc " Hz.")
   (bind ?resistance (askOptionalPositive
      "Enter a resistor value in ohms, or u if you do not have one:"))
   (if (numberp ?resistance) then
      (assert (r1 ?resistance))
      (assert (resistorChoice given))
   else
      (assert (resistorChoice unknown))
   )
) ; defrule need-r1Ask "asks for a resistor once the first-order cutoff is known"

/*
** A supplied resistor fixes the capacitor by fc = 1 / (2 * pi * R * C).
** The capacitor asserted as c1 is the nearest stocked E12 value. An ideal
** value outside the stocked decades ends the consultation.
*/
(defrule need-c1FromResistor "derives the E12 capacitor from a supplied resistor and the cutoff"
   (need-c1 ?)
   (cutoff ?fc)
   (resistorChoice given)
   (r1 ?resistance)
=>
   (bind ?ideal (/ 1.0 (* 2.0 (pi) ?resistance ?fc)))
   (if (withinE12Range ?ideal ?*CAPACITOR_SCALES*) then
      (printline "Ideal capacitor: " (translateSIPrefix ?ideal "F"))
      (assert (c1 (nearestE12 ?ideal ?*CAPACITOR_SCALES*)))
   else
      (printline "No stocked E12 capacitor can realize that cutoff with this resistor.")
      (printline "Required capacitor: " (translateSIPrefix ?ideal "F"))
      (printline "Stocked range: " (translateSIPrefix (e12Limit min ?*CAPACITOR_SCALES*) "F")
         " to " (translateSIPrefix (e12Limit max ?*CAPACITOR_SCALES*) "F"))
   ) ; if (withinE12Range ?ideal ?*CAPACITOR_SCALES*)
) ; defrule need-c1FromResistor "derives the E12 capacitor from a supplied resistor and the cutoff"

/*
** Asks for a capacitor only after the user left the resistor unknown.
** The r1 goal is still open, so Jess has not requested c1 yet. A numeric
** answer is stored as c1. u is recorded so the tolerance search can run.
*/
(defrule ask-c1WhenResistorUnknown "asks for a capacitor when the resistor was left unknown"
   (cutoff ?fc)
   (resistorChoice unknown)
   (not (capacitorChoice ?))
=>
   (if (> ?fc 0) then
      (bind ?capacitance (askOptionalPositive
         "Enter a capacitor value in farads, or u if you do not have one:"))
      (if (numberp ?capacitance) then
         (assert (c1 ?capacitance))
         (assert (capacitorChoice given))
      else
         (assert (capacitorChoice unknown))
      )
   else
   ) ; if (> ?fc 0)
) ; defrule ask-c1WhenResistorUnknown "asks for a capacitor when the resistor was left unknown"

/*
** A supplied capacitor fixes the resistor by fc = 1 / (2 * pi * R * C).
** The resistor asserted as r1 is the nearest stocked E12 value.
*/
(defrule need-r1FromCapacitor "derives the E12 resistor from a supplied capacitor and the cutoff"
   (need-r1 ?)
   (cutoff ?fc)
   (resistorChoice unknown)
   (capacitorChoice given)
   (c1 ?capacitance)
=>
   (bind ?ideal (/ 1.0 (* 2.0 (pi) ?capacitance ?fc)))
   (if (withinE12Range ?ideal ?*RESISTOR_SCALES*) then
      (printline "Ideal resistor: " (translateSIPrefix ?ideal "Ω"))
      (assert (r1 (nearestE12 ?ideal ?*RESISTOR_SCALES*)))
   else
      (printline "No stocked E12 resistor can realize that cutoff with this capacitor.")
      (printline "Required resistor: " (translateSIPrefix ?ideal "Ω"))
      (printline "Stocked range: " (translateSIPrefix (e12Limit min ?*RESISTOR_SCALES*) "Ω")
         " to " (translateSIPrefix (e12Limit max ?*RESISTOR_SCALES*) "Ω"))
   ) ; if (withinE12Range ?ideal ?*RESISTOR_SCALES*)
) ; defrule need-r1FromCapacitor "derives the E12 resistor from a supplied capacitor and the cutoff"

/*
** Neither part was supplied. The r1 goal is still open. Ask for the cutoff
** error in percent, search the stocked E12 resistors and capacitors, and
** assert r1 and c1 together. No pair inside the tolerance ends the consultation.
*/
(defrule select-rcWhenBothUnknown "selects an E12 pair when neither part value was supplied"
   (need-r1 ?)
   (cutoff ?fc)
   (resistorChoice unknown)
   (capacitorChoice unknown)
=>
   (bind ?tolerance (askPositivePercent
      "Maximum cutoff-frequency error in percent (example: 5):"))
   (bind ?pair (selectStandardPair ?fc ?tolerance))
   (bind ?resistance (nth$ 1 ?pair))
   (bind ?capacitance (nth$ 2 ?pair))
   (if (numberp ?resistance) then
      (printline crlf "Closest E12 pair within the tolerance:")
      (assert (r1 ?resistance))
      (assert (c1 ?capacitance))
   else
      (printline "No E12 resistor and capacitor pair stays within "
         ?tolerance " percent of " ?fc " Hz.")
   ) ; if (numberp ?resistance)
) ; defrule select-rcWhenBothUnknown "selects an E12 pair when neither part value was supplied"


/*
** ==========================================================
** Here are the forward chained rules.
*/

/*
** This rule is triggered when the user doesn't know what the types of filter approximations are.
*/
(defrule approximationsAskIndirectly "asks indirectly for the filter approximation if the user can't answer directly"
   (tryApproximationsAgain)
=>
   (bind ?ans (askOptions "What matters most for how your filter handles different frequencies? 
   A. The frequencies that are kept should have as little variation in gain as possible.
   B. The filter should distinguish the frequencies I keep and reject as sharply as possible.
   C. The filter should preserve the signal's shape and timing as well as possible.
   D. I don't know.
  " (create$ a b c d)))

   (if (= ?ans a) then 
      (assert (approximationType butterworth))
   )
   (if (= ?ans b) then
      (assert (approximationType chebyshev))
   )
   (if (= ?ans c) then
      (assert (approximationType bessel))
   ) 
   (if (= ?ans d) then
      (assert (approximationType u)) ; unknown
   )
)


/*
** ==================================================
** Here are the rules that will recommend the user a circuit diagram.
*/

/*
** Recommends the first-order Butterworth low-pass filter once backward
** chaining has asserted the cutoff, resistor, and capacitor. The schematic
** rule opens the window after this rule records that the consultation is done.
*/
(defrule recommendUnityGainFirstOrderButterworthLowPass 
      "recommends a unity gain first-order Butterworth low-pass recommendation"
   (lowPass y)
   (approximationType butterworth)
   (order 1)
   (cutoff ?fc)
   (gain 1)
   (r1 ?resistance)
   (c1 ?capacitance)
=>
   (reportRCPair ?resistance ?capacitance ?fc)
   (bind ?r1 (translateSIPrefix ?resistance "Ω"))
   (bind ?c1 (translateSIPrefix ?capacitance "F"))
   (bind ?schematic (call CircuitGraphics drawFirstOrderButterworthLowPassUnityGain ?r1 ?c1))
   (showSchematic ?schematic "First-order Butterworth low-pass filter")
   (assert (done))
) ; defrule recommendUnityGainFirstOrderButterworthLowPass


(defrule recommendNonInvFirstOrderButterworthLowPass "recommends a non-inverting 
      first-order Butterworth low-pass recommendation"
   (lowPass y)
   (approximationType butterworth)
   (order 1)
   (cutoff ?fc)
   (gain ?x)
   (r1 ?resistance)
   (c1 ?capacitance)
=>
   (if (and (numberp ?x) (> ?x 1)) then
      (reportRCPair ?resistance ?capacitance ?fc)
      (bind ?r1 (translateSIPrefix ?resistance "Ω"))
      (bind ?c1 (translateSIPrefix ?capacitance "F"))
      (bind ?schematic (call CircuitGraphics drawFirstOrderButterworthLowPassNonInv
         ?r1 ?c1 "Rg" "Rf"))
      (showSchematic ?schematic "First-order Butterworth non-inverting low-pass filter")
      (assert (done))
   ) ; if gain is greater than unity
) ; defrule recommendNonInvFirstOrderButterworthLowPass

/*
** These are the initial/ending rules for "I don't know" and the welcome message.
*/
(defrule initialDescription "Prints out a description and welcome statement"
   (declare (salience ?*INITIAL_SALIENCE*))
=>
   (print "Welcome to the Active Filter Expert System. This expert system will help you decide what active
filter to use and will recommend a high-level circuit schematic with resistor and capacitor values.

Please follow the instructions and answer the questions properly. Only the first character of your
token will be read, so inputting a 'yes' and a 'y' will produce the same result." crlf crlf crlf)
)

(defrule unsure "at the end, if the user doesn't know."
   (declare (salience ?*UNSURE_SALIENCE*))
   (not (done))
=>
   (print "I don't know what circuit to recommend to you. The circuit you have in mind may not be
supported by this expert system as of right now. Sorry!" crlf)
)