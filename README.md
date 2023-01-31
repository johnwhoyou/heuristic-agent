# Gold Miner Heuristic Agent
A machine project submission for the course, Intelligent Systems (CSINTSY).

An implementation of the A* Search Algorithm. This project was built on Godot Engine.

The task involves a miner agent searching for a gold block. The agent does not know the location of the gold block and can only detect objects in its line of sight (Pit, Beacon, Gold) when it performs a scan. However, the agent does not have information on the exact location of the detected object in that line of sight and the agent can only turn clockwise or move forward.

The beacon assists in returning a value for where the gold is in terms of Manhattan Distance, which causes the agent to calculate a grid of squares where the gold might be. 

Pits are tiles that end the game. In order to reach the goal state, the agent must avoid these tiles.
