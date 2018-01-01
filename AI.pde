final int AI_LEARN = 0;
final int AI_WIN = 1;

class AI {
  int state;
  State s;
  
  AI() {
    state = AI_LEARN;
    s = new Winning();
  }

  public int getMove() {
    switch(state) {
      case AI_LEARN:
      return s.getMove();
      case AI_WIN:
      return getBestMove();
    }
    
    return 0;
  }

  // returns the 1D index of the best move
  int getBestMove() {
    float[][] chances = current_board.getWinChances(current_turn == first_turn);
    
    ArrayList<int[]> indices = new ArrayList<int[]>();

    int[] points = new int[2]; 
    float highest_chance = -999;
    
    for(int r=0; r<3; r++) {
      for(int c=0; c<3; c++) {
        
        if(chances[r][c] > highest_chance) {
          highest_chance = chances[r][c];
          points = new int[2];
          points[0] = r;
          points[1] = c;
          indices.clear();
          indices.add(points);
        } else if (chances[r][c] == highest_chance) {
          points = new int[2];
          points[0] = r;
          points[1] = c;
          indices.add(points);
        }
      }
    }
    
    int[] index = indices.get(int(random(indices.size())));
    //println();
    //println(indices.size());
    //println();
    //println(index[0] + " " + index[1]);
    return index[0]*3 + index[1];
  }
  
}