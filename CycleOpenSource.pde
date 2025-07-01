/*
CYCLE by Gerard Valls Montaño (bygerardvisuals.com/cycle)
-----------------------------------------------------------

This sketch generates a visual animation based on a text message.
First, it displays the message on screen, then it dynamically breaks it apart.
At the end, it automatically saves a PNG image capture.

HOW TO USE:
- Open this file in Processing or p5.js, depending on the version.
- Change the message text in the variable 'message'.
- Adjust the timing if you wish:
  - staticTime → seconds before the animation starts
  - movementTime → duration of the decomposition
- Run the sketch. The animation uses a 9:16 (vertical) format.
- When it finishes, a PNG image (e.g., Capture_Cycle_001.png) will be
  automatically saved. Files are auto-numbered to avoid overwriting.

QUICK EDIT EXAMPLE:
  message = "Access to housing is a right, not a privilege.";
  staticTime = 2;
  movementTime = 15;

LICENSE:
This code is free and open source.
It is licensed under the terms of the **GNU Affero General Public License v3 (AGPL v3)**.

YOU MAY:
- Use it freely (for personal, artistic, educational or commercial purposes).
- Modify and adapt it.
- Generate artworks and sell them.

YOU MUST:
- Attribute the original author (Gerard Valls Montaño).
- Share any modified version of the code under the same license (AGPL v3),
  especially if used in networked environments or public platforms.
- Keep this license and attribution notice visible in your version.

SUGGESTED ATTRIBUTION (for derived works or artworks):
> Generated using code developed by Gerard Valls Montaño  
> https://bygerardvisuals.com/cycle — Licensed under AGPL v3

Full license text: https://www.gnu.org/licenses/agpl-3.0.en.html
*/


// --- BASIC SETTINGS ---

String message = "Access to housing is a right, not a privilege.";
int staticTime = 1;
int movementTime = 120;

color[] selectedPalette = {
  #1e1f26, #283655, #4d648d, #d0e1f9, #ffffff
};

// --- INTERNAL VARIABLES ---

PFont font;
ArrayList<Letter> letters = new ArrayList<Letter>();

int staticFrame, finalFrame;
boolean decompose = false;
boolean animationFinished = false;
boolean frozen = false;
boolean finalCaptureDone = false;

int decomposeStartTime;
int sketchStartTime;

float scaleFactor = 2.0;

// --- WINDOW CONFIGURATION ---

void settings() {
  size(540, 960, P2D);
}

void setup() {
  frameRate(30);
  surface.setLocation(0, 0);

  font = createFont("Georgia", 32 * scaleFactor);
  textFont(font);
  textAlign(CENTER, CENTER);

  staticFrame = staticTime * int(frameRate);
  finalFrame = (staticTime + movementTime) * int(frameRate);

  distributeLetters();
  sketchStartTime = millis();

  println("Message: " + message);
  println("Animation duration: " + movementTime + " seconds.");
}

void draw() {
  if (finalCaptureDone) return;

  if (!decompose) {
    background(0); // Black background only before decomposition
  }
  // After decomposition starts: no background → trails remain

  for (Letter l : letters) {
    l.update();
    l.display();
  }

  if (frozen && !finalCaptureDone) {
    String filename = getNextAvailableFilename("Capture_Cycle", ".png");
    saveFrame(filename);
    println("Saved capture: " + filename);
    finalCaptureDone = true;
    noLoop();
    return;
  }

  if (!animationFinished && decompose && millis() - decomposeStartTime >= movementTime * 1000) {
    animationFinished = true;
    frozen = true;
    return;
  }

  if (!decompose && millis() - sketchStartTime >= staticTime * 1000) {
    decompose = true;
    decomposeStartTime = millis();
    for (Letter l : letters) l.startDecomposition();
  }
}

// --- LETTER DISTRIBUTION ---

void distributeLetters() {
  letters.clear();
  int columns = int(sqrt(message.length()));
  int rows = ceil((float)message.length() / columns);
  float marginX = width * 0.1;
  float marginY = height * 0.1;
  float spaceX = (width - 2 * marginX) / columns;
  float spaceY = (height - 2 * marginY) / rows;

  int index = 0;
  for (int row = 0; row < rows; row++) {
    for (int col = 0; col < columns; col++) {
      if (index >= message.length()) return;
      char c = message.charAt(index);
      float x = marginX + col * spaceX + spaceX / 2;
      float y = marginY + row * spaceY + spaceY / 2;
      letters.add(new Letter(c, x, y));
      index++;
    }
  }
}

// --- LETTER CLASS ---

class Letter {
  char c;
  PVector initialPos, currentPos, target;
  float rotation, currentRotation;
  float scale, currentScale;
  color solidColor, trailColor;

  Letter(char c, float x, float y) {
    this.c = c;
    initialPos = new PVector(x, y);
    currentPos = initialPos.copy();
    target = generateNewTarget();
    rotation = random(-PI, PI);
    currentRotation = 0;
    scale = random(0.5, 2.0);
    currentScale = 1;

    color base = selectedPalette[int(random(selectedPalette.length))];
    solidColor = color(base);
    trailColor = color(red(base), green(base), blue(base), 80);
  }

  void startDecomposition() {
  }

  void update() {
    if (decompose && !animationFinished && !frozen) {
      currentPos.lerp(target, 0.05);
      currentRotation = lerp(currentRotation, rotation, 0.05);
      currentScale = lerp(currentScale, scale, 0.05);

      if (PVector.dist(currentPos, target) < 1) {
        target = generateNewTarget();
        rotation = random(-PI, PI);
        scale = random(0.5, 2.0);
      }
    }
  }

  void display() {
    pushMatrix();
    translate(currentPos.x, currentPos.y);
    rotate(currentRotation);
    scale(currentScale);
    fill(decompose ? trailColor : solidColor);
    text(c, 0, 0);
    popMatrix();
  }

  PVector generateNewTarget() {
    return PVector.random2D().mult(random(100 * scaleFactor, 300 * scaleFactor)).add(currentPos);
  }
}

// --- AUTOMATIC FILE NAME FOR FINAL CAPTURE ---

String getNextAvailableFilename(String prefix, String extension) {
  int counter = 1;
  String path;
  do {
    path = sketchPath(prefix + counter + extension);
    counter++;
  } while (new File(path).exists());
  return path;
}
