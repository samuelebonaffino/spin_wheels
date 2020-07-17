import processing.sound.*;
import controlP5.*;

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
float K = 0.2;

void setup() 
{
    size(512, 512);
    initGrid();
    initAudio("quadrant.wav");
    initControl();
    addNeighbours2();
    println(N);
    colorMode(HSB, 360, 360, 360);
}

void draw()
{
    drawGrid();
}

void initGrid()
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

void initAudio(String audio)
{
    input = new SoundFile(this, audio);
    fft = new FFT(this, B);
    amp = new Amplitude(this);

    input.play();
    fft.input(input);
    amp.input(input);
}

void initControl()
{
    cp5 = new ControlP5(this);
    cp5.addNumberbox("K")
       .setPosition(10, 10)
       .setSize(30, 15)
       .setRange(-1, 1)
       .setMultiplier(0.05)
       .setDirection(Controller.HORIZONTAL)
       .setValue(0.2);
}

void addNeighbours()
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

void addNeighbours2()
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

void drawGrid()
{
    fft.analyze(spectrum);
    float a = amp.analyze();
    for(int i = 0; i < N; i++)
    {
        grid[i].sync(spectrum, amp);
        grid[i].draw();
    }
}