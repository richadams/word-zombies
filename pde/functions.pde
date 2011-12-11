// These are just some helper functions used in the game.

// Start and stop animation processing
void stop()  { Processing.getInstanceById("wz").noLoop(); }
void start() { Processing.getInstanceById("wz").loop(); }

