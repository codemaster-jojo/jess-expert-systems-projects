/*
** Jonny Tang
** November 19, 2026
** 
** This file contains helper functions used in the main.clp file for various tasks.
** 
** Functions:
** askOptions          - asks a multiple choice question, and keeps asking user for the answer until it is valid.
** askYNU              - asks a yes/no/unknown question, and keeps asking the user for the answer until it is valid.
** askNumber           - asks for a number, and keeps asking the user for the answer until it is valid.
** askOptionalPositive - reads a positive number, or u when the user has no value.
** askPositivePercent  - reads a positive percent and rejects unknown or non-positive answers.
** expandE12           - builds the stocked E12 list by scaling each mantissa by each decade.
** e12Limit            - returns the smallest or largest value of an E12 series.
** withinE12Range      - returns TRUE when a target lies inside the stocked E12 range.
** nearestE12          - returns the stocked E12 value closest to a target.
** cutoffFrequency     - returns 1 / (2 * pi * R * C) in hertz.
** percentError        - returns the absolute percent difference of an actual value from a target.
** translateSIPrefix   - prints a value with an SI prefix, cut off at ENGINEERING_DECIMALS.
** reportRCPair        - prints a resistor, capacitor, the cutoff they produce, and the percent error.
** selectStandardPair  - searches stocked E12 parts for the closest pair within a cutoff tolerance.
** drawResistorImage   - draws one resistor on a transparent image and returns that image.
** showSchematic       - opens a window showing an image and returns the frame.
*/

/*
** =================================================
** HELPER FUNCTIONS
** =================================================
*/

/*
** This function handles most of the input/user interface. It prints out a question, and keeps reading
** an answer until it is valid. $?options will always be alphabets representing a limited set of options
** (i.e. either y/n/u for yes, no, unknown; or a/b/c/d/etc.)
*/
(deffunction askOptions (?question $?options)
   (print ?question " ")
   (bind ?ans (sym-cat (lowcase (sub-string 1 1 (read))))) ; gets lowercase first char of answer

   (while (not (subsetp (create$ ?ans) $?options))
      (print "Invalid input. Please try again. ")
      (bind ?ans (sym-cat (lowcase (sub-string 1 1 (read))))) 
   ) ; while (not (subsetp (create$ ?ans) $?options))

   (return ?ans)
) ; deffunction askOptions (question $?options)

/*
** This function uses askOptions to ask yes/no/unknown questions.
*/
(deffunction askYNU (?question)
   (return (askOptions ?question (create$ y n u)))
)

/*
** Asks for an integer or decimal and keeps reading until the answer is a number.
*/
(deffunction askNumber (?question)
   (print ?question " ")
   (bind ?ans (read)) ; reads one token, which is a number for input like 10 or 3.14

   (while (and (not (numberp ?ans))
               (neq (lowcase (sub-string 1 1 (str-cat ?ans))) "u"))
      (print "Invalid input. Enter a number or a value starting with u for unknown. ")
      (bind ?ans (read))
   ) ; while (not (numberp ?ans))

   (if (numberp ?ans) then
      (return ?ans)
   )
   (return u)
) ; deffunction askNumber (?question)

/*
** Reads a positive number. u is allowed and means the user has no value.
** Zero and negative numbers are rejected and the question is repeated.
*/
(deffunction askOptionalPositive (?question)
   (bind ?value (askNumber ?question))

   (while (and (numberp ?value) (<= ?value 0))
      (bind ?value (askNumber "Enter a positive number, or u if unknown:"))
   ) ; while (and (numberp ?value) (<= ?value 0))

   (return ?value)
) ; deffunction askOptionalPositive (?question)

/*
** Reads a percent such as 5 for five percent. Unknown and non-positive
** answers are rejected.
*/
(deffunction askPositivePercent (?question)
   (bind ?percent (askNumber ?question))

   (while (or (not (numberp ?percent)) (<= ?percent 0))
      (bind ?percent (askNumber "Enter a positive percent, for example 5:"))
   ) ; while (or (not (numberp ?percent)) (<= ?percent 0))

   (return ?percent)
) ; deffunction askPositivePercent (?question)

/*
** Builds the stocked E12 list by scaling each mantissa by each decade in
** $?scales. The scales must be positive and should be in ascending order.
*/
(deffunction expandE12 ($?scales)
   (bind ?series (create$))

   (foreach ?scale $?scales
      (foreach ?base ?*E12_BASES*
         (bind ?series (create$ ?series (* ?base ?scale)))
      ) ; foreach ?base ?*E12_BASES*
   ) ; foreach ?scale $?scales

   (return ?series)
) ; deffunction expandE12 ($?scales)

/*
** Returns the first or last value of an E12 series. ?which must be min or max.
** $?scales selects the decades, and the series must not be empty.
*/
(deffunction e12Limit (?which $?scales)
   (bind ?series (expandE12 $?scales))
   (bind ?limit (nth$ (length$ ?series) ?series))

   (if (eq ?which min) then
      (bind ?limit (nth$ 1 ?series))
   )

   (return ?limit)
) ; deffunction e12Limit (?which $?scales)

/*
** Returns TRUE when ?target lies between the smallest and largest stocked
** E12 value for $?scales, including the endpoints.
*/
(deffunction withinE12Range (?target $?scales)
   (bind ?inside FALSE)

   (if (and (numberp ?target)
            (>= ?target (e12Limit min $?scales))
            (<= ?target (e12Limit max $?scales))) then
      (bind ?inside TRUE)
   )

   (return ?inside)
) ; deffunction withinE12Range (?target $?scales)

/*
** Returns the stocked E12 value whose absolute distance to ?target is smallest.
** $?scales selects the decades that are searched.
*/
(deffunction nearestE12 (?target $?scales)
   (bind ?best nil)
   (bind ?bestGap nil)

   (foreach ?candidate (expandE12 $?scales)
      (bind ?gap (abs (- ?candidate ?target)))
      (if (or (not (numberp ?best)) (< ?gap ?bestGap)) then
         (bind ?best ?candidate)
         (bind ?bestGap ?gap)
      )
   ) ; foreach ?candidate (expandE12 $?scales)

   (return ?best)
) ; deffunction nearestE12 (?target $?scales)

/*
** Returns the cutoff 1 / (2 * pi * R * C) in hertz. Both parts must be positive.
*/
(deffunction cutoffFrequency (?resistance ?capacitance)
   (bind ?twoPi (* 2.0 (pi)))

   (return (/ 1.0 (* ?twoPi ?resistance ?capacitance)))
) ; deffunction cutoffFrequency (?resistance ?capacitance)

/*
** Returns the absolute percent difference of ?actual from ?target.
** ?target must not be zero.
*/
(deffunction percentError (?actual ?target)
   (bind ?percentScale 100.0)

   (return (* ?percentScale (/ (abs (- ?actual ?target)) ?target)))
) ; deffunction percentError (?actual ?target)

/*
** Returns ?value with an SI prefix and ?unit, for example 0.00005 and "Ω"
** become "50μΩ". The coefficient is cut off (not rounded) to
** ENGINEERING_DECIMALS places, and trailing zeros after the decimal are
** removed. ?value must be a number. ?unit is appended as given.
*/
(deffunction translateSIPrefix (?value ?unit)
   (bind ?text (str-cat ?value ?unit))

   (if (numberp ?value) then
      (if (= ?value 0) then
         (bind ?text (str-cat 0 ?unit))
      else
         (bind ?sign "")
         (bind ?magnitude (abs ?value))
         (if (< ?value 0) then
            (bind ?sign "-")
         )
         (bind ?decades (/ (log ?magnitude) (log ?*DECADE_SCALE*)))
         (bind ?groups (/ ?decades ?*SI_EXPONENT_STEP*))
         (bind ?groupCount (integer ?groups))
         (if (and (< ?groups 0) (<> ?groups ?groupCount)) then
            (bind ?groupCount (- ?groupCount 1))
         )
         (bind ?exponent (* ?groupCount ?*SI_EXPONENT_STEP*))
         (bind ?minExponent (nth$ (length$ ?*SI_EXPONENTS*) ?*SI_EXPONENTS*))
         (bind ?maxExponent (nth$ 1 ?*SI_EXPONENTS*))
         (if (< ?exponent ?minExponent) then
            (bind ?exponent ?minExponent)
         )
         (if (> ?exponent ?maxExponent) then
            (bind ?exponent ?maxExponent)
         )
         (bind ?scaled (/ ?magnitude (** ?*DECADE_SCALE* ?exponent)))
         (bind ?factor (** ?*DECADE_SCALE* ?*ENGINEERING_DECIMALS*))
         (bind ?truncationSlack 1.0e-9)
         (bind ?truncated (/ (integer (+ (* ?scaled ?factor) ?truncationSlack)) ?factor))
         (bind ?thousand (** ?*DECADE_SCALE* ?*SI_EXPONENT_STEP*))
         (if (>= ?truncated ?thousand) then
            (bind ?exponent (+ ?exponent ?*SI_EXPONENT_STEP*))
            (bind ?truncated (/ ?truncated ?thousand))
         )
         (bind ?prefix "")
         (bind ?index 1)
         (foreach ?candidate ?*SI_EXPONENTS*
            (if (= ?candidate ?exponent) then
               (bind ?prefix (nth$ ?index ?*SI_PREFIXES*))
            )
            (bind ?index (+ ?index 1))
         ) ; foreach ?candidate ?*SI_EXPONENTS*
         (bind ?number (format nil (str-cat "%." ?*ENGINEERING_DECIMALS* "f") ?truncated))
         (if (str-index "." ?number) then
            (while (eq (sub-string (str-length ?number) (str-length ?number) ?number) "0")
               (bind ?number (sub-string 1 (- (str-length ?number) 1) ?number))
            )
            (if (eq (sub-string (str-length ?number) (str-length ?number) ?number) ".") then
               (bind ?number (sub-string 1 (- (str-length ?number) 1) ?number))
            )
         )
         (bind ?text (str-cat ?sign ?number ?prefix ?unit))
      ) ; if (= ?value 0)
   ) ; if (numberp ?value)

   (return ?text)
) ; deffunction translateSIPrefix (?value ?unit)

/*
** Prints a chosen resistor, capacitor, the cutoff they produce, and the
** percent error from ?fc. Both component values must be positive.
*/
(deffunction reportRCPair (?resistance ?capacitance ?fc)
   (bind ?displayScale 100.0)
   (bind ?actual (cutoffFrequency ?resistance ?capacitance))
   (bind ?error (percentError ?actual ?fc))
   (bind ?shownError (/ (round (* ?error ?displayScale)) ?displayScale))

   (printline "Resistor: " (translateSIPrefix ?resistance "Ω"))
   (printline "Capacitor: " (translateSIPrefix ?capacitance "F"))
   (printline "Resulting cutoff: " (translateSIPrefix ?actual "Hz"))
   (printline "Cutoff error: " ?shownError " percent")
   (return TRUE)
) ; deffunction reportRCPair (?resistance ?capacitance ?fc)

/*
** Searches the stocked E12 resistors and capacitors for the pair whose cutoff
** is closest to ?fc without exceeding ?tolerance percent. Equal errors prefer
** the resistor closer to PREFERRED_RESISTOR. Returns (resistance capacitance
** error), using nil when no pair is inside the tolerance.
*/
(deffunction selectStandardPair (?fc ?tolerance)
   (bind ?bestR nil)
   (bind ?bestC nil)
   (bind ?bestError nil)
   (bind ?resistors (expandE12 ?*RESISTOR_SCALES*))
   (bind ?capacitors (expandE12 ?*CAPACITOR_SCALES*))

   (foreach ?resistance ?resistors
      (foreach ?capacitance ?capacitors
         (bind ?actual (cutoffFrequency ?resistance ?capacitance))
         (bind ?error (percentError ?actual ?fc))
         (if (<= ?error ?tolerance) then
            (bind ?takePair FALSE)
            (if (not (numberp ?bestR)) then
               (bind ?takePair TRUE)
            else
               (if (< ?error ?bestError) then
                  (bind ?takePair TRUE)
               else
                  (if (and (= ?error ?bestError)
                           (< (abs (- ?resistance ?*PREFERRED_RESISTOR*))
                              (abs (- ?bestR ?*PREFERRED_RESISTOR*)))) then
                     (bind ?takePair TRUE)
                  )
               ) ; if (< ?error ?bestError) then
            ) ; if (not (numberp ?bestR)) then
            (if ?takePair then
               (bind ?bestR ?resistance)
               (bind ?bestC ?capacitance)
               (bind ?bestError ?error)
            ) ; if ?takePair then
         ) ; if (<= ?error ?tolerance)
      ) ; foreach ?capacitance ?capacitors
   ) ; foreach ?resistance ?resistors

   (return (create$ ?bestR ?bestC ?bestError))
) ; deffunction selectStandardPair (?fc ?tolerance)

/*
** Creates a transparent image, obtains its Graphics2D object, draws one fixed-
** length resistor, and returns the image containing the drawing.
** The x/y coordinates and direction must place the resistor within the image.
** The caller can display or save the returned BufferedImage.
*/
(deffunction drawResistorImage (?x ?y ?direction)
   (bind ?image (new BufferedImage ?*SCHEMATIC_WIDTH* ?*SCHEMATIC_HEIGHT*
         (get-member BufferedImage TYPE_INT_ARGB)))
   (bind ?graphics (call ?image createGraphics))
   (call CircuitGraphics drawResistor ?graphics ?x ?y ?direction)
   (call CircuitGraphics releaseGraphics ?graphics)
   (return ?image)
) ; deffunction drawResistorImage (?x ?y ?direction)

/*
** Example call:
** (bind ?resistorImage
**    (drawResistorImage 40 150 (get-member CircuitGraphics$Direction RIGHT)))
*/

/*
** Opens a window showing ?image under ?title. Closing the window disposes it
** and does not exit Jess. The frame is kept in SCHEMATIC_FRAME and brought
** forward; a local variable alone can be collected before the window paints.
** ?image and ?title must not be nil. Returns the frame.
*/
(deffunction showSchematic (?image ?title)
   (bind ?frame (new JFrame ?title))
   (bind ?label (new JLabel (new ImageIcon ?image)))

   (call (call ?frame getContentPane) add ?label)
   (call ?frame setDefaultCloseOperation
      (get-member JFrame DISPOSE_ON_CLOSE))
   (call ?frame pack)
   (call ?frame setLocationRelativeTo nil)
   (call ?frame setVisible TRUE)
   (call ?frame toFront)
   (call ?frame requestFocus)
   (bind ?*SCHEMATIC_FRAME* ?frame)
   (return ?frame)
) ; deffunction showSchematic (?image ?title)