/*
CYCLE by Gerard Valls Montaño (bygerardvisuals.com/cycle)
p5.js version — Licensed under AGPL v3
*/

let message = "Access to housing is a right, not a privilege.";
let staticTime = 1;        // seconds before animation starts
let movementTime = 120;    // duration of decomposition in seconds

let selectedPalette = [
  '#1e1f26', '#283655', '#4d648d', '#d0e1f9', '#ffffff'
];

let letters = [];

let decompose = false;
let animationFinished = false;
let frozen = false;
let finalCaptureDone = false;

let decomposeStartTime = 0;
let sketchStartTime = 0;

let scaleFactor = 2.0;
let saveCounter = 1;

let font;

function preload() {
  font = loadFont('fonts/SourceCodePro-Regular.otf');
}

function setup() {
  createCanvas(540, 960);
  frameRate(30);
  textFont(font);
  textSize(32 * scaleFactor);
  textAlign(CENTER, CENTER);
  sketchStartTime = millis();
  distributeLetters();
  console.log("Message: " + message);
  console.log("Animation duration: " + movementTime + " seconds.");
}

function draw() {
  if (finalCaptureDone) return;

  if (!decompose) {
    background(0);
  }

  letters.forEach(l => {
    l.update();
    l.display();
  });

  if (frozen && !finalCaptureDone) {
    let filename = 'Capture_Cycle_' + nf(saveCounter, 3);
    saveCanvas(filename, 'png');
    console.log('Saved capture: ' + filename + '.png');
    saveCounter++;
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
    letters.forEach(l => l.startDecomposition());
  }
}

function distributeLetters() {
  letters = [];
  let columns = floor(sqrt(message.length));
  let rows = ceil(message.length / columns);
  let marginX = width * 0.1;
  let marginY = height * 0.1;
  let spaceX = (width - 2 * marginX) / columns;
  let spaceY = (height - 2 * marginY) / rows;

  let index = 0;
  for (let row = 0; row < rows; row++) {
    for (let col = 0; col < columns; col++) {
      if (index >= message.length) return;
      let c = message.charAt(index);
      let x = marginX + col * spaceX + spaceX / 2;
      let y = marginY + row * spaceY + spaceY / 2;
      letters.push(new Letter(c, x, y));
      index++;
    }
  }
}

class Letter {
  constructor(c, x, y) {
    this.c = c;
    this.initialPos = createVector(x, y);
    this.currentPos = this.initialPos.copy();
    this.target = this.generateNewTarget();
    this.rotation = random(-PI, PI);
    this.currentRotation = 0;
    this.scale = random(0.5, 2.0);
    this.currentScale = 1;

    let base = color(random(selectedPalette));
    this.solidColor = base;
    this.trailColor = color(red(base), green(base), blue(base), 80);
  }

  startDecomposition() {
    // Puedes añadir lógica si lo necesitas
  }

  update() {
    if (decompose && !animationFinished && !frozen) {
      this.currentPos.lerp(this.target, 0.05);
      this.currentRotation = lerp(this.currentRotation, this.rotation, 0.05);
      this.currentScale = lerp(this.currentScale, this.scale, 0.05);

      if (p5.Vector.dist(this.currentPos, this.target) < 1) {
        this.target = this.generateNewTarget();
        this.rotation = random(-PI, PI);
        this.scale = random(0.5, 2.0);
      }
    }
  }

  display() {
    push();
    translate(this.currentPos.x, this.currentPos.y);
    rotate(this.currentRotation);
    scale(this.currentScale);
    fill(decompose ? this.trailColor : this.solidColor);
    noStroke();
    text(this.c, 0, 0);
    pop();
  }

  generateNewTarget() {
    let randomVec = p5.Vector.random2D();
    randomVec.mult(random(100 * scaleFactor, 300 * scaleFactor));
    return p5.Vector.add(this.currentPos, randomVec);
  }
}
