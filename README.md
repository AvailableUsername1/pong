PONG GAME IMPLEMENTATION USING LOVE2D AND LUA PROGRAMMING LANGUAGE

I just followed along cs50's gamedev course and implemented pong.

On my part I implemented a simple AI that plays for player2. It just moves up if ball coordinates are higher than paddle coordinates and down if otherwise. It's almost impossible to beat it. The only time you have a chance is when the ball bounces of the wall very close to the AI and the angle is very steep so being limited by paddle speed it just can't arive in time to stop the ball from scoring.

To make the AI unbeatable maybe it should calculate the location of ball  impact and wait there instead of blindly fallowing the y coordinate of the ball.