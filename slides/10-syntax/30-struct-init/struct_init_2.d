alias C = void delegate();
void y() {}

C c = { x:y;};
