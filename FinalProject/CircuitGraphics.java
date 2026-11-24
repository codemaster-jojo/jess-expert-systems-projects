/*
 * Jonny Tang
 * November 19, 2026
 * 
 * This file provides Java2D helpers for drawing common circuit schematic symbols and wires.
 * The methods will be called in the expert system/JESS code to construct the circuit diagram.
 * 
 * Class CircuitGraphics contains these methods:
 * writeText         - Takes in position and text, displays it in the graphics object.
 * drawWire          - Draws a wire (line) from one point to another.
 * drawResistor      - Draws a resistor (zigzag) given a starting point and direction.
 * drawCapacitor     - Draws a capacitor (two parallel lines) given a starting point and direction.
 * drawOpAmp         - Draws an op-amp with + and - inputs and an output lead.
 * prepareSchematic  - Fills a black canvas and selects white antialiased lines.
 * setDrawColor      - Selects the color used by later drawing calls.
 * setLabelFont      - Selects the font used by writeText.
 * drawNode          - Fills a connection dot centered on a point.
 * drawRoundedBorder - Draws a rounded rectangular border.
 * releaseGraphics   - Disposes a schematic drawing context.
 * drawFirstOrderButterworthLowPassUnityGain - Draws the unity-gain version.
 * drawFirstOrderButterworthLowPassNonInv - Draws the resistor-feedback version.
 */

import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.geom.Line2D;
import java.awt.geom.Path2D;
import java.awt.image.BufferedImage;

/**
 * Provides helpers for drawing circuit symbols with Java2D.
 * Coordinates and dimensions are measured in pixels.
 */
public final class CircuitGraphics
{
   private static final double HALF_TURN = 2.0;
   private static final double RESISTOR_LEAD_RATIO = 0.2;
   private static final double RESISTOR_HEIGHT_RATIO = 0.12;
   private static final double CAPACITOR_GAP_RATIO = 0.12;
   private static final double CAPACITOR_PLATE_RATIO = 0.2;
   private static final double OP_AMP_UPPER_INPUT_RATIO = 0.32;
   private static final double OP_AMP_LOWER_INPUT_RATIO = 0.68;

   private static final int RESISTOR_LENGTH = 60;
   private static final int CAPACITOR_LENGTH = 40;
   private static final int MIN_OP_AMP_DIMENSION = 20;
   private static final int RESISTOR_MAX_LEAD = 12;
   private static final int RESISTOR_MAX_HEIGHT = 6;
   private static final int RESISTOR_MIN_HEIGHT = 2;
   private static final int RESISTOR_MIN_TEETH = 2;
   private static final int RESISTOR_MAX_TEETH = 8;
   private static final int RESISTOR_PIXELS_PER_TOOTH = 7;
   private static final int CAPACITOR_MAX_GAP = 8;
   private static final int CAPACITOR_MIN_GAP = 4;
   private static final int CAPACITOR_MAX_PLATE = 12;
   private static final int CAPACITOR_MIN_PLATE = 5;
   private static final int OP_AMP_LEAD_LENGTH = 18;
   private static final int OP_AMP_MARK_HALF_WIDTH = 4;
   private static final int OP_AMP_MARK_CENTER_X = 10;
   private static final int OP_AMP_MARK_START_X = 6;
   private static final int OP_AMP_MARK_END_X = 14;
   private static final float SCHEMATIC_LINE_WIDTH = 2.0f;
   private static final int SCHEMATIC_FONT_SIZE = 15;
   private static final String SCHEMATIC_FONT_NAME = "SansSerif";

   private static final int FILTER_IMAGE_WIDTH = 1000;
   private static final int FILTER_UNITY_IMAGE_HEIGHT = 310;
   private static final int FILTER_NONINV_IMAGE_HEIGHT = 370;
   private static final int FILTER_TITLE_X = 24;
   private static final int FILTER_TITLE_Y = 34;
   private static final int FILTER_TITLE_SIZE = 16;
   private static final int FILTER_LABEL_SIZE = 15;
   private static final int FILTER_BORDER_X = 12;
   private static final int FILTER_BORDER_Y = 50;
   private static final int FILTER_BORDER_WIDTH = 976;
   private static final int FILTER_UNITY_BORDER_HEIGHT = 250;
   private static final int FILTER_NONINV_BORDER_HEIGHT = 310;
   private static final int FILTER_BORDER_ARC = 18;
   private static final int FILTER_SIGNAL_Y = 150;
   private static final int FILTER_VIN_TEXT_X = 28;
   private static final int FILTER_VIN_TEXT_Y = 155;
   private static final int FILTER_VIN_WIRE_X = 74;
   private static final int FILTER_RESISTOR_X = 104;
   private static final int FILTER_JUNCTION_X = 250;
   private static final int FILTER_OP_AMP_X = 390;
   private static final int FILTER_OP_AMP_WIDTH = 100;
   private static final int FILTER_OP_AMP_HEIGHT = 100;
   private static final int FILTER_OUTPUT_JUNCTION_X = 700;
   private static final int FILTER_VOUT_END_X = 880;
   private static final int FILTER_VOUT_TEXT_GAP = 12;
   private static final int FILTER_VOUT_TEXT_DY = 5;
   private static final int FILTER_LABEL_GAP = 32;
   private static final int FILTER_R_LABEL_DX = 18;
   private static final int FILTER_C_LABEL_GAP = 16;
   private static final int FILTER_C_LABEL_DY = 24;
   private static final int FILTER_GROUND_DROP = 36;
   private static final int FILTER_FEEDBACK_DROP = 10;
   private static final int FILTER_FEEDBACK_LABEL_DX = 210;
   private static final int FILTER_FEEDBACK_LABEL_DY = 18;
   private static final int FILTER_FOLLOWER_LABEL_DX = 150;
   private static final int FILTER_FOLLOWER_LABEL_DY = 26;
   private static final int FILTER_FEEDBACK_X = 650;
   private static final int FILTER_FEEDBACK_TOP_Y = 150;
   private static final int FILTER_FEEDBACK_MID_Y = 250;
   private static final int FILTER_FEEDBACK_BOTTOM_Y = 340;
   private static final int FILTER_FEEDBACK_GROUND_DROP = 36;
   private static final int FILTER_NODE_DIAMETER = 8;
   private static final int GROUND_TOP_HALF_WIDTH = 14;
   private static final int GROUND_MID_HALF_WIDTH = 9;
   private static final int GROUND_LOW_HALF_WIDTH = 4;
   private static final int GROUND_BAR_GAP = 6;
   private static final String FILTER_UNITY_GAIN_TITLE =
      "First-order Butterworth low-pass filter (unity-gain buffer):";
   private static final String FILTER_NONINV_TITLE =
      "First-order Butterworth low-pass filter (non-inverting op-amp):";

   /**
    * Prevents instances of this static utility class.
    */
   private CircuitGraphics()
   {
   } // CircuitGraphics()

   /**
    * Describes the axis along which a component extends from its first
    * terminal (UP,DOWN,LEFT,RIGHT)
    */
   public enum Direction
   {
      RIGHT(0.0),
      DOWN(Math.PI / HALF_TURN),
      LEFT(Math.PI),
      UP(-Math.PI / HALF_TURN);

      private final double radians;

      /**
       * Stores the rotation used to draw in this direction.
       *
       * @param radians rotation from the positive horizontal axis
       */
      Direction(double radians)
      {
         this.radians = radians;
      } // Direction(double)
   } // Direction

   /**
    * Draws text with its baseline beginning at the supplied position.
    *
    * @param g destination drawing context; must not be null
    * @param x horizontal position of the text baseline
    * @param y vertical position of the text baseline
    * @param text text to draw; must not be null
    * @throws IllegalArgumentException if the drawing context or text is null
    */
   public static void writeText(Graphics2D g, int x, int y, String text)
   {
      if (g == null || text == null)
      {
         throw new IllegalArgumentException("Graphics and text are required");
      } // if (g == null || text == null)

      g.drawString(text, x, y);
   } // writeText(Graphics2D, int, int, String)

   /**
    * Draws a straight wire between two points.
    *
    * @param g destination drawing context; must not be null
    * @param x1 horizontal coordinate of the first endpoint
    * @param y1 vertical coordinate of the first endpoint
    * @param x2 horizontal coordinate of the second endpoint
    * @param y2 vertical coordinate of the second endpoint
    * @throws IllegalArgumentException if the drawing context is null
    */
   public static void drawWire(Graphics2D g, int x1, int y1, int x2, int y2)
   {
      requireGraphics(g);
      g.draw(new Line2D.Double(x1, y1, x2, y2));
   } // drawWire(Graphics2D, int, int, int, int)

   /**
    * Draws a fixed-length zig-zag resistor from a first terminal along the
    * given direction. The terminal-to-terminal length is RESISTOR_LENGTH.
    *
    * @param g destination drawing context; must not be null
    * @param x horizontal coordinate of the first terminal
    * @param y vertical coordinate of the first terminal
    * @param direction direction from the first terminal; must not be null
    * @throws IllegalArgumentException if the drawing context or direction is
    *         null
    */
   public static void drawResistor(Graphics2D g, int x, int y,
         Direction direction)
   {
      requireComponent(g, direction);

      Graphics2D componentGraphics = oriented(g, x, y, direction);
      try
      {
         double leadLength = Math.min(RESISTOR_MAX_LEAD,
            RESISTOR_LENGTH * RESISTOR_LEAD_RATIO);
         double bodyStart = leadLength;
         double bodyEnd = RESISTOR_LENGTH - leadLength;
         double amplitude = Math.min(RESISTOR_MAX_HEIGHT, Math.max(RESISTOR_MIN_HEIGHT,
            RESISTOR_LENGTH * RESISTOR_HEIGHT_RATIO));
         int teeth = Math.max(RESISTOR_MIN_TEETH, Math.min(RESISTOR_MAX_TEETH,
            (int) ((bodyEnd - bodyStart) / RESISTOR_PIXELS_PER_TOOTH)));

         componentGraphics.draw(new Line2D.Double(0.0, 0.0, bodyStart, 0.0));

         Path2D zigzag = new Path2D.Double();
         zigzag.moveTo(bodyStart, 0.0);
         for (int step = 1; step < teeth * 2; step++)
         {
            double pointX = bodyStart + (bodyEnd - bodyStart) * step
               / (teeth * 2.0);
            double pointY = step % 2 == 1 ? -amplitude : amplitude;
            zigzag.lineTo(pointX, pointY);
         } // for (int step = 1; step < teeth * 2; step++)
         zigzag.lineTo(bodyEnd, 0.0);

         componentGraphics.draw(zigzag);
         componentGraphics.draw(new Line2D.Double(bodyEnd, 0.0,
            RESISTOR_LENGTH, 0.0));
      } // try
      finally
      {
         componentGraphics.dispose();
      } // finally
   } // drawResistor(Graphics2D, int, int, Direction)

   /**
    * Draws a fixed-length two-plate capacitor from a first terminal along the
    * given direction. The terminal-to-terminal length is CAPACITOR_LENGTH.
    *
    * @param g destination drawing context; must not be null
    * @param x horizontal coordinate of the first terminal
    * @param y vertical coordinate of the first terminal
    * @param direction direction from the first terminal; must not be null
    * @throws IllegalArgumentException if the drawing context or direction is
    *         null
    */
   public static void drawCapacitor(Graphics2D g, int x, int y,
      Direction direction)
   {
      requireComponent(g, direction);

      Graphics2D componentGraphics = oriented(g, x, y, direction);
      try
      {
         double center = CAPACITOR_LENGTH / HALF_TURN;
         double gap = Math.min(CAPACITOR_MAX_GAP,
            Math.max(CAPACITOR_MIN_GAP, CAPACITOR_LENGTH * CAPACITOR_GAP_RATIO));
         double plateLength = Math.min(CAPACITOR_MAX_PLATE,
            Math.max(CAPACITOR_MIN_PLATE, CAPACITOR_LENGTH * CAPACITOR_PLATE_RATIO));

         componentGraphics.draw(new Line2D.Double(0.0, 0.0,
            center - gap / HALF_TURN, 0.0));
         componentGraphics.draw(new Line2D.Double(center + gap / HALF_TURN, 0.0, CAPACITOR_LENGTH, 0.0));
         componentGraphics.draw(new Line2D.Double(center - gap / HALF_TURN, 
            -plateLength, center - gap / HALF_TURN, plateLength));
         componentGraphics.draw(new Line2D.Double(center + gap / HALF_TURN,
            -plateLength, center + gap / HALF_TURN, plateLength));
      }
      finally
      {
         componentGraphics.dispose();
      } // finally
   } // drawCapacitor(Graphics2D, int, int, Direction)

   /**
    * Draws an op-amp with a triangular body, labeled inputs, and output lead.
    * The upper input is marked + and the lower input is marked -.
    * The position is the upper-left corner of the unrotated triangle bounds.
    * Width and height must each be at least MIN_OP_AMP_DIMENSION pixels.
    *
    * @param g destination drawing context; must not be null
    * @param x horizontal coordinate of the triangle's upper-left corner
    * @param y vertical coordinate of the triangle's upper-left corner
    * @param direction direction the triangle tip faces; must not be null
    * @param width width of the triangular body in pixels
    * @param height height of the triangular body in pixels
    * @throws IllegalArgumentException if an argument requirement is not met
    */
   public static void drawOpAmp(Graphics2D g, int x, int y,
      Direction direction, int width, int height)
   {
      requireGraphics(g);
      if (direction == null || width < MIN_OP_AMP_DIMENSION
         || height < MIN_OP_AMP_DIMENSION)
      {
         throw new IllegalArgumentException(
            "Direction is required and op-amp dimensions must be at least "
            + MIN_OP_AMP_DIMENSION);
      } // if (direction == null || width < MIN_OP_AMP_DIMENSION || height < MIN_OP_AMP_DIMENSION)

      Graphics2D componentGraphics = oriented(g, x, y, direction);
      try
      {
         double middle = height / HALF_TURN;
         Path2D triangle = new Path2D.Double();
         triangle.moveTo(0.0, 0.0);
         triangle.lineTo(0.0, height);
         triangle.lineTo(width, middle);
         triangle.closePath();
         componentGraphics.draw(triangle);

         double upperInputY = height * OP_AMP_UPPER_INPUT_RATIO;
         double lowerInputY = height * OP_AMP_LOWER_INPUT_RATIO;
         double inputX = -OP_AMP_LEAD_LENGTH;
         componentGraphics.draw(new Line2D.Double(inputX, upperInputY, 0.0, upperInputY));
         componentGraphics.draw(new Line2D.Double(inputX, lowerInputY, 0.0, lowerInputY));
         componentGraphics.draw(new Line2D.Double(width, middle, width + OP_AMP_LEAD_LENGTH, middle));

         componentGraphics.draw(new Line2D.Double(OP_AMP_MARK_START_X,
            upperInputY, OP_AMP_MARK_END_X, upperInputY));
         componentGraphics.draw(new Line2D.Double(OP_AMP_MARK_CENTER_X,
            upperInputY - OP_AMP_MARK_HALF_WIDTH, OP_AMP_MARK_CENTER_X,
            upperInputY + OP_AMP_MARK_HALF_WIDTH));
         componentGraphics.draw(new Line2D.Double(OP_AMP_MARK_START_X,
            lowerInputY, OP_AMP_MARK_END_X, lowerInputY));
      }
      finally
      {
         componentGraphics.dispose();
      } // finally
   } // drawOpAmp(Graphics2D, int, int, Direction, int, int)

   /**
    * Fills the image black, then selects white antialiased lines and the
    * default schematic font. Later calls can change the color and font.
    * Width and height must be positive and are the image size in pixels.
    *
    * @param g destination drawing context; must not be null
    * @param width image width in pixels; must be positive
    * @param height image height in pixels; must be positive
    * @throws IllegalArgumentException if the drawing context is null or the
    *         size is not positive
    */
   public static void prepareSchematic(Graphics2D g, int width, int height)
   {
      requireGraphics(g);
      if (width <= 0 || height <= 0)
      {
         throw new IllegalArgumentException(
            "Schematic width and height must be positive");
      } // if (width <= 0 || height <= 0)

      g.setRenderingHint(RenderingHints.KEY_ANTIALIASING,
         RenderingHints.VALUE_ANTIALIAS_ON);
      g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING,
         RenderingHints.VALUE_TEXT_ANTIALIAS_ON);
      g.setColor(Color.BLACK);
      g.fillRect(0, 0, width, height);
      g.setColor(Color.WHITE);
      g.setStroke(new BasicStroke(SCHEMATIC_LINE_WIDTH));
      g.setFont(new Font(SCHEMATIC_FONT_NAME, Font.PLAIN, SCHEMATIC_FONT_SIZE));
   } // prepareSchematic(Graphics2D, int, int)

   /**
    * Selects the color used by later drawing calls.
    *
    * @param g destination drawing context; must not be null
    * @param color drawing color; must not be null
    * @throws IllegalArgumentException if the drawing context or color is null
    */
   public static void setDrawColor(Graphics2D g, Color color)
   {
      requireGraphics(g);
      if (color == null)
      {
         throw new IllegalArgumentException("Color is required");
      } // if (color == null)

      g.setColor(color);
   } // setDrawColor(Graphics2D, Color)

   /**
    * Selects the font used by writeText. Style is a Font style constant such
    * as Font.PLAIN or Font.BOLD. Size is the point size and must be positive.
    *
    * @param g destination drawing context; must not be null
    * @param style Font style constant; must not be negative
    * @param size point size; must be positive
    * @throws IllegalArgumentException if an argument requirement is not met
    */
   public static void setLabelFont(Graphics2D g, int style, int size)
   {
      requireGraphics(g);
      if (style < 0 || size <= 0)
      {
         throw new IllegalArgumentException(
            "Font style must be non-negative and size must be positive");
      } // if (style < 0 || size <= 0)

      g.setFont(new Font(SCHEMATIC_FONT_NAME, style, size));
   } // setLabelFont(Graphics2D, int, int)

   /**
    * Fills a connection dot centered on the supplied point. Diameter is the
    * dot size in pixels and must be positive.
    *
    * @param g destination drawing context; must not be null
    * @param x horizontal center of the dot
    * @param y vertical center of the dot
    * @param diameter dot diameter in pixels; must be positive
    * @throws IllegalArgumentException if the drawing context is null or the
    *         diameter is not positive
    */
   public static void drawNode(Graphics2D g, int x, int y, int diameter)
   {
      requireGraphics(g);
      if (diameter <= 0)
      {
         throw new IllegalArgumentException("Node diameter must be positive");
      } // if (diameter <= 0)

      int radius = diameter / 2;

      g.fillOval(x - radius, y - radius, diameter, diameter);
   } // drawNode(Graphics2D, int, int, int)

   /**
    * Draws a rounded rectangular border. Width, height, and arc must be
    * positive. The arc is used for both corner diameters.
    *
    * @param g destination drawing context; must not be null
    * @param x horizontal coordinate of the border's upper-left corner
    * @param y vertical coordinate of the border's upper-left corner
    * @param width border width in pixels; must be positive
    * @param height border height in pixels; must be positive
    * @param arc corner diameter in pixels; must be positive
    * @throws IllegalArgumentException if an argument requirement is not met
    */
   public static void drawRoundedBorder(Graphics2D g, int x, int y,
      int width, int height, int arc)
   {
      requireGraphics(g);
      if (width <= 0 || height <= 0 || arc <= 0)
      {
         throw new IllegalArgumentException(
            "Border width, height, and arc must be positive");
      } // if (width <= 0 || height <= 0 || arc <= 0)

      g.drawRoundRect(x, y, width, height, arc, arc);
   } // drawRoundedBorder(Graphics2D, int, int, int, int, int)

   /**
    * Disposes a drawing context created for a schematic. The context must not
    * be used after this call.
    *
    * @param g drawing context to dispose; must not be null
    * @throws IllegalArgumentException if the drawing context is null
    */
   public static void releaseGraphics(Graphics2D g)
   {
      requireGraphics(g);
      g.dispose();
   } // releaseGraphics(Graphics2D)

   /**
    * Draws the three horizontal bars of a ground symbol. The caller draws the
    * stem that ends at (x, y). The longest bar is centered on that point and
    * the shorter bars are stacked below it.
    *
    * @param g destination drawing context; must not be null
    * @param x horizontal center of the ground bars
    * @param y vertical position of the longest bar
    */
   private static void drawGround(Graphics2D g, int x, int y)
   {
      int middleBarY = y + GROUND_BAR_GAP;
      int lowBarY = middleBarY + GROUND_BAR_GAP;

      drawWire(g, x - GROUND_TOP_HALF_WIDTH, y, x + GROUND_TOP_HALF_WIDTH, y);
      drawWire(g, x - GROUND_MID_HALF_WIDTH, middleBarY,
         x + GROUND_MID_HALF_WIDTH, middleBarY);
      drawWire(g, x - GROUND_LOW_HALF_WIDTH, lowBarY,
         x + GROUND_LOW_HALF_WIDTH, lowBarY);
   } // drawGround(Graphics2D, int, int)

   /**
    * Draws a first-order Butterworth low-pass filter: a series resistor, a
    * capacitor from the RC junction to ground, and an op-amp voltage follower.
    * The resistor and capacitor labels are drawn beside those parts.
    *
    * @param resistorLabel text drawn at the resistor, such as "R1 = 3.3kΩ";
    *        must not be null
    * @param capacitorLabel text drawn at the capacitor, such as "C1 = 47nF";
    *        must not be null
    * @return the finished schematic image
    * @throws IllegalArgumentException if either label is null
    */
   public static BufferedImage drawFirstOrderButterworthLowPassUnityGain(
      String resistorLabel, String capacitorLabel)
   {
      if (resistorLabel == null || capacitorLabel == null)
      {
         throw new IllegalArgumentException(
            "Resistor and capacitor labels are required");
      } // if (resistorLabel == null || capacitorLabel == null)

      int upperOffset = (int) (FILTER_OP_AMP_HEIGHT * OP_AMP_UPPER_INPUT_RATIO);
      int lowerOffset = (int) (FILTER_OP_AMP_HEIGHT * OP_AMP_LOWER_INPUT_RATIO);
      int outputOffset = (int) (FILTER_OP_AMP_HEIGHT / HALF_TURN);
      int opAmpY = FILTER_SIGNAL_Y - upperOffset;
      int minusY = opAmpY + lowerOffset;
      int outputY = opAmpY + outputOffset;
      int plusLeadX = FILTER_OP_AMP_X - OP_AMP_LEAD_LENGTH;
      int outputLeadX = FILTER_OP_AMP_X + FILTER_OP_AMP_WIDTH + OP_AMP_LEAD_LENGTH;
      int resistorEnd = FILTER_RESISTOR_X + RESISTOR_LENGTH;
      int capacitorEndY = FILTER_SIGNAL_Y + CAPACITOR_LENGTH;
      int groundY = capacitorEndY + FILTER_GROUND_DROP;
      int feedbackY = opAmpY + FILTER_OP_AMP_HEIGHT + FILTER_FEEDBACK_DROP;

      BufferedImage image = new BufferedImage(FILTER_IMAGE_WIDTH,
         FILTER_UNITY_IMAGE_HEIGHT, BufferedImage.TYPE_INT_ARGB);
      Graphics2D graphics = image.createGraphics();
      try
      {
         prepareSchematic(graphics, FILTER_IMAGE_WIDTH, FILTER_UNITY_IMAGE_HEIGHT);
         setLabelFont(graphics, Font.BOLD, FILTER_TITLE_SIZE);
         writeText(graphics, FILTER_TITLE_X, FILTER_TITLE_Y, FILTER_UNITY_GAIN_TITLE);

         setDrawColor(graphics, Color.LIGHT_GRAY);
         drawRoundedBorder(graphics, FILTER_BORDER_X, FILTER_BORDER_Y,
            FILTER_BORDER_WIDTH, FILTER_UNITY_BORDER_HEIGHT, FILTER_BORDER_ARC);

         setDrawColor(graphics, Color.WHITE);
         setLabelFont(graphics, Font.PLAIN, FILTER_LABEL_SIZE);
         drawWire(graphics, FILTER_VIN_WIRE_X, FILTER_SIGNAL_Y,
            FILTER_RESISTOR_X, FILTER_SIGNAL_Y);
         drawResistor(graphics, FILTER_RESISTOR_X, FILTER_SIGNAL_Y, Direction.RIGHT);
         drawWire(graphics, resistorEnd, FILTER_SIGNAL_Y,
            FILTER_JUNCTION_X, FILTER_SIGNAL_Y);
         drawWire(graphics, FILTER_JUNCTION_X, FILTER_SIGNAL_Y,
            plusLeadX, FILTER_SIGNAL_Y);
         drawCapacitor(graphics, FILTER_JUNCTION_X, FILTER_SIGNAL_Y, Direction.DOWN);
         drawWire(graphics, FILTER_JUNCTION_X, capacitorEndY,
            FILTER_JUNCTION_X, groundY);
         drawGround(graphics, FILTER_JUNCTION_X, groundY);
         drawOpAmp(graphics, FILTER_OP_AMP_X, opAmpY, Direction.RIGHT,
            FILTER_OP_AMP_WIDTH, FILTER_OP_AMP_HEIGHT);
         drawWire(graphics, outputLeadX, outputY,
            FILTER_OUTPUT_JUNCTION_X, outputY);
         drawWire(graphics, FILTER_OUTPUT_JUNCTION_X, outputY,
            FILTER_VOUT_END_X, outputY);
         drawWire(graphics, FILTER_OUTPUT_JUNCTION_X, outputY,
            FILTER_OUTPUT_JUNCTION_X, feedbackY);
         drawWire(graphics, FILTER_OUTPUT_JUNCTION_X, feedbackY,
            plusLeadX, feedbackY);
         drawWire(graphics, plusLeadX, feedbackY, plusLeadX, minusY);
         drawNode(graphics, FILTER_JUNCTION_X, FILTER_SIGNAL_Y, FILTER_NODE_DIAMETER);
         drawNode(graphics, FILTER_OUTPUT_JUNCTION_X, outputY, FILTER_NODE_DIAMETER);
         writeText(graphics, FILTER_VIN_TEXT_X, FILTER_VIN_TEXT_Y, "Vin");
         writeText(graphics, FILTER_RESISTOR_X + FILTER_R_LABEL_DX,
            FILTER_SIGNAL_Y - FILTER_LABEL_GAP, "R1 = " + resistorLabel);
         writeText(graphics, FILTER_JUNCTION_X + FILTER_C_LABEL_GAP,
            FILTER_SIGNAL_Y + FILTER_C_LABEL_DY, "C1 = " + capacitorLabel);
         writeText(graphics, FILTER_VOUT_END_X + FILTER_VOUT_TEXT_GAP,
            outputY + FILTER_VOUT_TEXT_DY, "Vout");
         writeText(graphics, plusLeadX + FILTER_FEEDBACK_LABEL_DX,
            feedbackY - FILTER_FEEDBACK_LABEL_DY, "Feedback");
         writeText(graphics, plusLeadX + FILTER_FOLLOWER_LABEL_DX,
            feedbackY + FILTER_FOLLOWER_LABEL_DY, "Op-amp voltage follower");
      } // try
      finally
      {
         graphics.dispose();
      } // finally

      return image;
   } // drawFirstOrderButterworthLowPassUnityGain(String, String)

   /**
    * Draws the RC low-pass followed by a non-inverting op-amp. Rf connects
    * output to the inverting-input divider node; Rg connects that node to
    * ground. All labels are required.
    */
   public static BufferedImage drawFirstOrderButterworthLowPassNonInv(
      String resistorLabel, String capacitorLabel,
      String rgLabel, String rfLabel)
   {
      if (resistorLabel == null || capacitorLabel == null
         || rgLabel == null || rfLabel == null)
      {
         throw new IllegalArgumentException("All resistor and capacitor labels are required");
      } // if labels are null

      BufferedImage image = new BufferedImage(FILTER_IMAGE_WIDTH,
         FILTER_NONINV_IMAGE_HEIGHT, BufferedImage.TYPE_INT_ARGB);
      Graphics2D graphics = image.createGraphics();
      try
      {
         prepareSchematic(graphics, FILTER_IMAGE_WIDTH, FILTER_NONINV_IMAGE_HEIGHT);
         setLabelFont(graphics, Font.BOLD, FILTER_TITLE_SIZE);
         writeText(graphics, FILTER_TITLE_X, FILTER_TITLE_Y, FILTER_NONINV_TITLE);
         setDrawColor(graphics, Color.LIGHT_GRAY);
         drawRoundedBorder(graphics, FILTER_BORDER_X, FILTER_BORDER_Y,
            FILTER_BORDER_WIDTH, FILTER_NONINV_BORDER_HEIGHT, FILTER_BORDER_ARC);

         setDrawColor(graphics, Color.WHITE);
         setLabelFont(graphics, Font.PLAIN, FILTER_LABEL_SIZE);
         int upperOffset = (int) (FILTER_OP_AMP_HEIGHT * OP_AMP_UPPER_INPUT_RATIO);
         int lowerOffset = (int) (FILTER_OP_AMP_HEIGHT * OP_AMP_LOWER_INPUT_RATIO);
         int opAmpY = FILTER_SIGNAL_Y - lowerOffset;
         int plusY = opAmpY + lowerOffset;
         int minusY = opAmpY + upperOffset;
         int outputY = opAmpY + (int) (FILTER_OP_AMP_HEIGHT / HALF_TURN);
         int plusX = FILTER_OP_AMP_X - OP_AMP_LEAD_LENGTH;
         int outputX = FILTER_OP_AMP_X + FILTER_OP_AMP_WIDTH + OP_AMP_LEAD_LENGTH;
         int resistorEnd = FILTER_RESISTOR_X + RESISTOR_LENGTH;
         int capacitorEndY = FILTER_SIGNAL_Y + CAPACITOR_LENGTH;
         int capacitorGroundY = capacitorEndY + FILTER_GROUND_DROP;
         int feedbackX = FILTER_FEEDBACK_X;
         int rfStartY = outputY + 20;
         int dividerY = rfStartY + RESISTOR_LENGTH + 20;
         int rgStartY = dividerY + 10;
         int rgEndY = rgStartY + RESISTOR_LENGTH;

         drawWire(graphics, FILTER_VIN_WIRE_X, FILTER_SIGNAL_Y,
            FILTER_RESISTOR_X, FILTER_SIGNAL_Y);
         drawResistor(graphics, FILTER_RESISTOR_X, FILTER_SIGNAL_Y, Direction.RIGHT);
         drawWire(graphics, resistorEnd, FILTER_SIGNAL_Y, FILTER_JUNCTION_X, FILTER_SIGNAL_Y);
         drawWire(graphics, FILTER_JUNCTION_X, FILTER_SIGNAL_Y, plusX, FILTER_SIGNAL_Y);
         drawCapacitor(graphics, FILTER_JUNCTION_X, FILTER_SIGNAL_Y, Direction.DOWN);
         drawWire(graphics, FILTER_JUNCTION_X, capacitorEndY, FILTER_JUNCTION_X, capacitorGroundY);
         drawGround(graphics, FILTER_JUNCTION_X, capacitorGroundY);
         drawOpAmp(graphics, FILTER_OP_AMP_X, opAmpY, Direction.RIGHT,
            FILTER_OP_AMP_WIDTH, FILTER_OP_AMP_HEIGHT);
         drawWire(graphics, outputX, outputY, FILTER_VOUT_END_X, outputY);

         drawWire(graphics, FILTER_OUTPUT_JUNCTION_X, outputY,
            FILTER_OUTPUT_JUNCTION_X, rfStartY);
         drawWire(graphics, FILTER_OUTPUT_JUNCTION_X, outputY,
            FILTER_VOUT_END_X, outputY);
         drawWire(graphics, FILTER_OUTPUT_JUNCTION_X, outputY,
            feedbackX, outputY);
         drawWire(graphics, feedbackX, outputY, feedbackX, rfStartY);
         drawResistor(graphics, feedbackX, rfStartY, Direction.DOWN);
         drawWire(graphics, feedbackX, rfStartY + RESISTOR_LENGTH,
            feedbackX, dividerY);
         drawNode(graphics, feedbackX, dividerY, FILTER_NODE_DIAMETER);
         drawWire(graphics, feedbackX, dividerY, feedbackX, rgStartY);
         drawResistor(graphics, feedbackX, rgStartY, Direction.DOWN);
         drawWire(graphics, feedbackX, rgEndY, feedbackX, rgEndY + FILTER_GROUND_DROP);
         drawGround(graphics, feedbackX, rgEndY + FILTER_GROUND_DROP);
         drawWire(graphics, feedbackX, dividerY, plusX - 30, dividerY);
         drawWire(graphics, plusX - 30, dividerY, plusX - 30, minusY);
         drawWire(graphics, plusX - 30, minusY, plusX, minusY);
         drawNode(graphics, FILTER_JUNCTION_X, FILTER_SIGNAL_Y, FILTER_NODE_DIAMETER);
         drawNode(graphics, FILTER_OUTPUT_JUNCTION_X, outputY, FILTER_NODE_DIAMETER);
         writeText(graphics, FILTER_VIN_TEXT_X, FILTER_VIN_TEXT_Y, "Vin");
         writeText(graphics, FILTER_RESISTOR_X + FILTER_R_LABEL_DX,
            FILTER_SIGNAL_Y - FILTER_LABEL_GAP, "R1 = " + resistorLabel);
         writeText(graphics, FILTER_JUNCTION_X + FILTER_C_LABEL_GAP,
            FILTER_SIGNAL_Y + FILTER_C_LABEL_DY, "C1 = " + capacitorLabel);
         writeText(graphics, FILTER_VOUT_END_X + FILTER_VOUT_TEXT_GAP,
            outputY + FILTER_VOUT_TEXT_DY, "Vout");
         writeText(graphics, feedbackX + 15, rfStartY + RESISTOR_LENGTH / 2, "Rf = " + rfLabel);
         writeText(graphics, feedbackX + 15, rgStartY + RESISTOR_LENGTH / 2, "Rg = " + rgLabel);
      }
      finally
      {
         graphics.dispose();
      } // finally
      return image;
   } // drawFirstOrderButterworthLowPassNonInv(String, String, String, String)

   /**
    * Creates a child drawing context translated to a component origin and
    * rotated to the component direction. The caller must dispose the result.
    *
    * @param g source drawing context; must not be null
    * @param x horizontal coordinate of the component origin
    * @param y vertical coordinate of the component origin
    * @param direction direction of the component; must not be null
    * @return translated and rotated child drawing context
    */
   private static Graphics2D oriented(Graphics2D g, int x, int y,
      Direction direction)
   {
      Graphics2D componentGraphics = (Graphics2D) g.create();
      componentGraphics.translate(x, y);
      componentGraphics.rotate(direction.radians);

      return componentGraphics;
   } // oriented(Graphics2D, int, int, Direction)

   /**
    * Checks that a drawing context is present.
    *
    * @param g drawing context to check
    * @throws IllegalArgumentException if the drawing context is null
    */
   private static void requireGraphics(Graphics2D g)
   {
      if (g == null)
      {
         throw new IllegalArgumentException("Graphics2D is required");
      } // if (g == null)
   } // requireGraphics(Graphics2D)

   /**
    * Checks that the drawing context and component direction are present.
    *
    * @param g drawing context to check
    * @param direction component direction to check
    * @throws IllegalArgumentException if the drawing context or direction is
    *         null
    */
   private static void requireComponent(Graphics2D g, Direction direction)
   {
      requireGraphics(g);
      if (direction == null)
      {
         throw new IllegalArgumentException("Direction is required");
      } // if (direction == null)
   } // requireComponent(Graphics2D, Direction)
} // public final class CircuitGraphics
