abstract class State {
  abstract int getMove();
}

class Learning extends State { 
  int getMove() {
    return 0;
  }
}

class HeuristicMove extends State 
{
  int getMove() 
  {
    int[] selected = new int[2];
    
    float[][] heuristics = current_board.getChildHeuristic(current_turn == first_turn);
    
    int[] points = new int[2];
    float highest = -999; // we find the highest heuristic value
    
    ArrayList<int[]> tied_indices = new ArrayList<int[]>();
    
    for(int r=0; r<3; r++)
    {
      for(int c=0; c<3; c++)
      {
        if (heuristics[r][c] > highest && heuristics[r][c] != -1.0)
        {
          highest = heuristics[r][c];
          
          tied_indices.clear();
          tied_indices.add(new int[] {r, c});
        }
        else if (heuristics[r][c] == highest) 
        {
          tied_indices.add(new int[] {r, c});
        }
      }
    }
    
    selected = tied_indices.get((int) random(tied_indices.size()-1));
    
   // println();
  //  println(selected[0] + " " + selected[1]);
    return selected[0]*3 + selected[1];
  }
}

class Winning extends State {
  int getMove() {
    float[][] win_chances = current_board.getChildWinChances(current_turn == first_turn);
    float[][] loss_chances = current_board.getChildLossChances(current_turn == first_turn);

    ArrayList<int[]> loss_indices = new ArrayList<int[]>();

    int[] points = new int[2]; 
    float lowest_chance = 999; // find the lowest chance of losing

    for (int r=0; r<3; r++) {
      for (int c=0; c<3; c++) { 
        if (loss_chances[r][c] < lowest_chance && loss_chances[r][c] != -1.0) {
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

    int[] index = null;

    //if there's a tie for lowest loss chance, look for highest win chance among the ties  
    if (loss_indices.size() > 1) {
      println("tied for losses");

      float highest_chance = -999; // find the highest chance of winning
      ArrayList<int[]> win_indices = new ArrayList<int[]>();

      for(int i=0; i<loss_indices.size(); i++) {
        points = loss_indices.get(i);
        if(win_chances[points[0]][points[1]] > highest_chance) {
          win_indices.clear();
          win_indices.add(points);
          highest_chance = win_chances[points[0]][points[1]];
        } else if (win_chances[points[0]][points[1]] == highest_chance) {
          win_indices.add(points);
        }
      }

      index = win_indices.get(int(random(win_indices.size())));
    } else {

      float[][] loss_chance = current_board.getChildLossChances(current_turn == first_turn);

      println();
      println("Loss Chances");
      for (int r=0; r<3; r++) {
        println();
        for (int c=0; c<3; c++) {
          print(" " + loss_chance[r][c] + " ");
        }
      }
      index = loss_indices.get(int(random(loss_indices.size())));
    }

    println();
    println(index[0] + " " + index[1]);
    return index[0]*3 + index[1];
  }
}