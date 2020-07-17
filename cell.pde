import java.util.ArrayList;

float t = 0;

class Cell
{
    final static int SIZE = 4;
    // final static float K = 0.2;
    // final static float K = 0.5;
    final static float ANGULAR_SPEED = 0.01;

    int id, x, y;
    float phaseH, phaseS, phaseB, w;
    color c;
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

    void draw()
    {
        updatePhase();
        phaseToColor();
        // stroke(c);
        // point(x, y);
        fill(c);
        noStroke();
        rect(x, y, SIZE, SIZE);
    }

    int timestep()
    {
        t += 0.01;
        if(t >= 3600)
            t = 0;
        return round(map(sin(t), -1, 1, 0, 360));
    }

    void phaseToColor()
    {
        int h = round(map(phaseH, 0, 2*PI, 0, 360));
        int s = round(map(phaseS, 0, 2*PI, 250, 360));
        int b = round(map(phaseB, 0, 2*PI, 0, 360));
        c = color(h, h, h, 50);
    }

    void resetPhase()
    {
        if(phaseH >= 2*PI)
            phaseH = 0;
        if(phaseS >= 2*PI)
            phaseS = 0;
        if(phaseB >= 2*PI)
            phaseB = 0;
    }

    void updatePhase()
    {
        phaseH += w + ANGULAR_SPEED;
        phaseS += w + ANGULAR_SPEED;
        phaseB += w + ANGULAR_SPEED;
        resetPhase();
    }

    void addNeighbour(Cell n)
    {
        ns.add(n);
    }

    void sync(float[] spectrum, Amplitude amp)
    {
        float tmp = 0;
        for(Cell n : ns)
            tmp += sin(n.phaseH-phaseH);
        float s = map(spectrum[id], 0, 1, 0.1, 0.5);
        // float s = spectrum[round(random(B-1))] * 10;
        // float s = spectrum[id] * 50;
        w = K*amp.analyze()*(s+tmp);
        // w = constrain(w, 0, 3/2*PI);
    }
}