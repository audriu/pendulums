import processing.sound.*;

ArrayList<Pendulum> pendulums;
final static int N_P = 7;
final static float T_MAX = 45;
final static float K = 34; 
final static int scaling = 2000;
final static float G = 9.81;
float[] octave = {0.25, 0.5, 1.0, 2.0, 4.0};
SoundFile[] file;
int numsounds = 5;
int soundNum = 2;

void setup() {
  size(700, 1000);
  frameRate(60);
  pendulums = new ArrayList<Pendulum>();
  for (int i = 0; i < N_P; i++) {
    float l = G * ((T_MAX) / (2 * PI * (K + i + 1))) * ((T_MAX) / (2 * PI * (K + i + 1)));
    l = map(l, 0, 1, 0, 2 * height - 10);
    Pendulum p = new Pendulum(new PVector(width/2, 50), l, new SinOsc(this), i, (255/N_P*i) + 1);
    pendulums.add(p);
  }
  
  // Create an array of empty soundfiles
  file = new SoundFile[numsounds];

  // Load 5 soundfiles from a folder in a for loop. By naming the files 1., 2., 3., n.aif it is easy to iterate
  // through the folder and load all files in one line of code.
  for (int i = 0; i < numsounds; i++) {
    file[i] = new SoundFile(this, (i+1) + ".aif");
  }
}

void draw() {
  background(200);

  stroke(0, 0, 0, 255);
  line(width/2, 50, width/2, 10000);
  
  for (Pendulum p : pendulums) {
    p.move();
    p.display();
  }
}

class Pendulum {
  PVector pivot;
  PVector pos;
  int num;
  float acc;
  float vel;
  float arm;
  float damping;
  float rad = 10;
  float angle;
  float mass = 1.0;
  float gravity = 9.81;
  float scaling = 0.05;
  SinOsc chime;
  int colorTone;
  
  public Pendulum(PVector pivot_, float arm, SinOsc chime, int num, int colorTone) {
    pivot = new PVector(pivot_.x, pivot_.y);
    this.vel = 0.0;
    this.arm = arm;
    this.angle = PI/6;
    this.damping = 1;
    float x = sin(angle) * arm;
    float y = cos(angle) * arm;
    this.pos = new PVector(this.pivot.x + x, this.pivot.y + y);
    this.chime = chime;
    this.num = num;
    this.colorTone = colorTone;
  }
  
  public void move() {
    acc = ((-G * scaling / arm) * sin(angle));
    vel += acc;
    vel *= damping;
    float newAngle = angle + vel;

    if (angle * newAngle < 0) {
      println("§ " + angle +" § "+ newAngle);
      playSound(num);
      
      //file.play();
      //playChime(arm);
    }
    
    angle = newAngle;
    pos.set(arm * sin(angle), arm * cos(angle), 0);
    pos.add(pivot);
  }
  
  public void display() {
    stroke(0, 0, 0, 30);
    line(pivot.x, pivot.y, pos.x, pos.y);
    noStroke();
    fill(20, 20, 20, colorTone);
    ellipse(pos.x, pos.y, rad*2, rad*2);
  }

  void playSound(int num) {
    float rate = octave[int(random(0, 5))];
    file[soundNum].play(rate, 1.0);
  }

  void playChime(float freq) {
   Thread chimeThread = new Thread(new Runnable() {
    @Override
    public void run() {
      try {
        chime.amp(1.0);
        chime.freq(freq * 0.5);
        chime.play();
        Thread.sleep(10);
        chime.amp(1.0);
        Thread.sleep(100);
        chime.amp(0.1);
        chime.stop();
      } catch (Exception e) {}
    }
  });
  chimeThread.start();
  }

}