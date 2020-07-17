import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.sound.*; 
import controlP5.*; 
import java.util.ArrayList; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class spin_wheels extends PApplet {




final static int W = 512;
final static int H = 512;
final static int N = W*H/(Cell.SIZE*Cell.SIZE);
// final static int B = W*H/4;
final static int B = 128;

Cell[] grid = new Cell[N];
float[] spectrum = new float[B];
FFT fft;
Amplitude amp;
SoundFile input;
ControlP5 cp5;

// CONTROL PARAMETERS
float K = 0.2f;

public void setup() 
{
    
    initGrid();
    initAudio("quadrant.wav");
    initControl();
    addNeighbours2();
    println(N);
    colorMode(HSB, 360, 360, 360);
}

public void draw()
{
    drawGrid();
}

public void initGrid()
{
    int c = 0, x = 0, y = -1;
    for(int i = 0; i < N; i++)
    {
        if(i%(W/Cell.SIZE) == 0)
        {
            x = 0;
            y++;
        }
        grid[i] = new Cell(c++, x*Cell.SIZE, y*Cell.SIZE);
        x++;
        if(c == B-1)
            c = 0;
    }
}

public void initAudio(String audio)
{
    input = new SoundFile(this, audio);
    fft = new FFT(this, B);
    amp = new Amplitude(this);

    input.play();
    fft.input(input);
    amp.input(input);
}

public void initControl()
{
    cp5 = new ControlP5(this);
    cp5.addNumberbox("K")
       .setPosition(10, 10)
       .setSize(30, 15)
       .setRange(-1, 1)
       .setMultiplier(0.05f)
       .setDirection(Controller.HORIZONTAL)
       .setValue(0.2f);
}

public void addNeighbours()
{
    int n = round(sqrt(N));
    for(int i = 0; i < n; i++)
        for(int j = 0; j < n; j++)
        {
            if((i > 0 && i < n-1) && (j > 0 && j < n-1))
            {
                for(int x = -1; x < 2; x++)
                    for(int y = -1; y < 2; y++)
                        grid[i*n+j].addNeighbour(grid[(i+x)*n+(j+y)]);
            }
        }
}

public void addNeighbours2()
{
    int n = round(sqrt(N));
    for(int i = 0; i < n; i++)
        for(int j = 0; j < n; j++)
        {
            if(i > 0 && j > 0)
                grid[i*n+j].addNeighbour(grid[(i-1)*n+j-1]);
            if(i > 0)
                grid[i*n+j].addNeighbour(grid[(i-1)*n+j]);
            if(i > 0 && j < n - 1)
                grid[i*n+j].addNeighbour(grid[(i-1)*n+j+1]);
            if(j > 0)
                grid[i*n+j].addNeighbour(grid[i*n+j-1]);
            if(j < n - 1)
                grid[i*n+j].addNeighbour(grid[i*n+j+1]);
            if(i < n - 1 && j > 0)
                grid[i*n+j].addNeighbour(grid[(i+1)*n+j-1]);
            if(i < n - 1)
                grid[i*n+j].addNeighbour(grid[(i+1)*n+j]);
            if(i < n - 1 && j < n - 1)
                grid[i*n+j].addNeighbour(grid[(i+1)*n+j+1]); 
        } 
}

public void drawGrid()
{
    fft.analyze(spectrum);
    float a = amp.analyze();
    for(int i = 0; i < N; i++)
    {
        grid[i].sync(spectrum, amp);
        grid[i].draw();
    }
}


float t = 0;

class Cell
{
    final static int SIZE = 4;
    // final static float K = 0.2;
    // final static float K = 0.5;
    final static float ANGULAR_SPEED = 0.01f;

    int id, x, y;
    float phaseH, phaseS, phaseB, w;
    int c;
    ArrayList<Cell> ns = new ArrayList<Cell>();

    Cell(int id, int x, int y)
    {
        this.id = id;
        this.x = x;
        this.y = y;
        phaseH = random(0, 2*PI);
        phaseS = random(0, 2*PI);
        phaseB = random(0, 2*PI);
        w = 0;
        // phaseH = log(id/PI+1);
        // phaseS = log(id/PI+1);
        // phaseB = log(id/PI+1);
        c = color(0);
    }

    public void draw()
    {
        updatePhase();
        phaseToColor();
        // stroke(c);
        // point(x, y);
        fill(c);
        noStroke();
        rect(x, y, SIZE, SIZE);
    }

    public int timestep()
    {
        t += 0.01f;
        if(t >= 3600)
            t = 0;
        return round(map(sin(t), -1, 1, 0, 360));
    }

    public void phaseToColor()
    {
        int h = round(map(phaseH, 0, 2*PI, 0, 360));
        int s = round(map(phaseS, 0, 2*PI, 250, 360));
        int b = round(map(phaseB, 0, 2*PI, 0, 360));
        c = color(h, h, h, 50);
    }

    public void resetPhase()
    {
        if(phaseH >= 2*PI)
            phaseH = 0;
        if(phaseS >= 2*PI)
            phaseS = 0;
        if(phaseB >= 2*PI)
            phaseB = 0;
    }

    public void updatePhase()
    {
        phaseH += w + ANGULAR_SPEED;
        phaseS += w + ANGULAR_SPEED;
        phaseB += w + ANGULAR_SPEED;
        resetPhase();
    }

    public void addNeighbour(Cell n)
    {
        ns.add(n);
    }

    public void sync(float[] spectrum, Amplitude amp)
    {
        float tmp = 0;
        for(Cell n : ns)
            tmp += sin(n.phaseH-phaseH);
        float s = map(spectrum[id], 0, 1, 0.1f, 0.5f);
        // float s = spectrum[round(random(B-1))] * 10;
        // float s = spectrum[id] * 50;
        w = K*amp.analyze()*(s+tmp);
        // w = constrain(w, 0, 3/2*PI);
    }
}
  public void settings() {  size(512, 512); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "spin_wheels" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
