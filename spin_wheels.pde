import processing.sound.*;

final static int W = 256;
final static int H = 256;
final static int N = W*H/(Cell.SIZE*Cell.SIZE);
// final static int B = W*H/4;
final static int B = 128;

Cell[] grid = new Cell[N];
float[] spectrum = new float[B];
FFT fft;
Amplitude amp;
SoundFile input;

// CONTROL PARAMETERS
float K;
float angularSpeed;

void setup() 
{
    size(256, 256);
    initGrid();
    initAudio("duality.wav");
    initControlSystem();
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