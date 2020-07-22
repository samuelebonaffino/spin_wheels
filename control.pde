import controlP5.*;

ControlP5 cp5_K;
ControlP5 cp5_angularSpeed;

void initControlSystem()
{
    cp5_K = initControl("K", 10, 0.01, 0);
    cp5_angularSpeed = initControl("angularSpeed", 30, 0.01, 0);
}

ControlP5 initControl(String name, int y, float mul, float start)
{
    ControlP5 cp5 = new ControlP5(this);
    cp5.addNumberbox(name)
       .setPosition(10, y)
       .setSize(30, 15)
       .setRange(-1, 1)
       .setMultiplier(mul)
       .setDirection(Controller.HORIZONTAL)
       .setValue(start);
    return cp5;
}