abstract class State {
  abstract int getMove();
}

class Learning extends State { 
  int getMove() {
    return 0;
  }
}

class Winning extends State {
  int getMove() {
    float[][] win_chances = current_board.getWinChances(current_turn == first_turn);
    float[][] loss_chances = current_board.getLossChances(current_turn == first_turn);
    
    ArrayList<int[]> win_indices = new ArrayList<int[]>();
    ArrayList<int[]> loss_indices = new ArrayList<int[]>();

    int[] points = new int[2]; 
    float highest_chance = -999; // find the highest chance of winning
    float lowest_chance = 999; // find the lowest chance of losing
    
    for(int r=0; r<3; r++) {
      for(int c=0; c<3; c++) {
        if(win_chances[r][c] > highest_chance) {
          highest_chance = win_chances[r][c];
          points = new int[2];
          points[0] = r;
          points[1] = c;
          win_indices.clear();
          win_indices.add(points);
        } else if (win_chances[r][c] == highest_chance) {
          points = new int[2];
          points[0] = r;
          points[1] = c;
          win_indices.add(points);
        }
        
        if(loss_chances[r][c] < lowest_chance && loss_chances[r][c] >= 0) {
          lowest_chance = loss_chances[r][c];
          points = new int[2];
          points[0] = r;
          points[1] = c;
          loss_indices.clear();
          loss_indices.add(points);
        } else if (loss_chances[r][c] == lowest_chance) {
          points = new int[2];
          points[0] = r;
          points[1] = c;
          loss_indices.add(points);
        }
      }
    }
    
   // int[] index = win_indices.get(int(random(win_indices.size())));
    //println("high: " + highest_chance + " Low: " + lowest_chance);
   // if(highest_chance < 0.1) {
    //  println("Trying to prevent loss");
     int[] index = loss_indices.get(int(random(loss_indices.size())));
    //}
    
    println();
    println(index[0] + " " + index[1]);
    return index[0]*3 + index[1];
  }
}