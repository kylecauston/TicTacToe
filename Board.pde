import java.util.HashMap; //<>// //<>// //<>// //<>// //<>//

final int BOARD_PLAYING = 0;
final int BOARD_ODD_WIN = 1;
final int BOARD_EVEN_WIN = 2;
final int BOARD_TIE = 3;

final char BLUE_TOKEN = 'B';
final char RED_TOKEN = 'R';

final float NO_DATA = 2.0;
final float SPOT_TAKEN = -1.0;

class Board {  
  char[][] tiling;

  int state = BOARD_PLAYING;

  int num_moves = 0;

  Statistic stats;

  Board() {
    stats = new Statistic();
    tiling = new char[3][3];
    num_moves = 0;
    
    for (int r=0; r<3; r++) {
      for (int c=0; c<3; c++) {
        tiling[r][c] = '0';
      }
    }
    
    boards.put("000000000", this);
  }

  Board(String s) {
    stats = new Statistic();
    tiling = new char[3][3];
    num_moves = 0;

    for (int r=0; r<3; r++) {
      for (int c=0; c<3; c++) {
        tiling[r][c] = s.charAt(r*3 + c);

        if (tiling[r][c] != '0') num_moves++;
      }
    }

    generateState();

    boards.put(s, this);
  }

  Board(char[][] prev_board, int r, int c) {
    this();

    String s = "";
    num_moves = 0;

    for (int R=0; R<3; R++) {
      for (int C=0; C<3; C++) {
        if (R == r && C == c) 
        {
          tiling[r][c] = (char) (num_moves + 1 + '0');
        } else { 
          tiling[R][C] = prev_board[R][C];
        }

        if (tiling[R][C] != '0') num_moves++;
        s += tiling[R][C];
      }
    }

    generateState();
    
    boards.put(s, this);
  }

  void setStatistic(Statistic s) {
    stats = s;
  }
  
  Statistic getStatistic() {
    return stats;
  }
  
  void addVictory(boolean even) {
    stats.addResult(even);
  }
  
  void addTie() {
    stats.addTie();
  }
  
  void generateState()
  {
    // make a tiling array of numerical values
    int[][] tile_vals = new int[3][3];
    for(int r=0; r<3; r++)
    {
      for(int c=0; c<3; c++)
      {
        tile_vals[r][c] = Character.getNumericValue(tiling[r][c]);
      }
    }

    
    // first check if the row was a victory
    boolean row_victory = false;
    boolean col_victory = false;
    boolean down_right_victory = false;
    boolean down_left_victory = false;

    // t represents which player we're looking for (p1 or 2)
    for (int t=1; t<3; t++) {              
      int remainder = t % 2; // start with odd player, then go to even

      for (int r=0; r<3; r++) {
        row_victory = row_victory
          || tile_vals[r][0] != 0 && tile_vals[r][0] % 2 == remainder
          && tile_vals[r][1] != 0 && tile_vals[r][1] % 2 == remainder
          && tile_vals[r][2] != 0 && tile_vals[r][2] % 2 == remainder;
      }

      for (int c=0; c<3; c++) {
        col_victory = col_victory
          || tile_vals[0][c] != 0 && tile_vals[0][c] % 2 == remainder
          && tile_vals[1][c] != 0 && tile_vals[1][c] % 2 == remainder
          && tile_vals[2][c] != 0 && tile_vals[2][c] % 2 == remainder;
      }

      down_right_victory = tile_vals[0][0] != 0 && tile_vals[0][0] % 2 == remainder
        && tile_vals[1][1] != 0 && tile_vals[1][1] % 2 == remainder
        && tile_vals[2][2] != 0 && tile_vals[2][2] % 2 == remainder;

      down_left_victory = tile_vals[0][2] != 0 && tile_vals[0][2] % 2 == remainder
        && tile_vals[1][1] != 0 && tile_vals[1][1] % 2 == remainder
        && tile_vals[2][0] != 0 && tile_vals[2][0] % 2 == remainder;
        
      if (row_victory || col_victory || down_right_victory || down_left_victory) {
        state = (remainder == 1) ? BOARD_ODD_WIN : BOARD_EVEN_WIN;
        break;
      } else if (num_moves == 9) {
        state = BOARD_TIE;
        break;
      }
    }
  }
  
  String toFileString() {
    return toString() + ":" + stats.toString();
  }

  @Override
  String toString() {
    String s = "";

    for (int r=0; r<3; r++) {
      for (int c=0; c<3; c++) {
        s += this.tiling[r][c];
      }
    }

    return s;
  }

  boolean isDone() {
    return !(state == BOARD_PLAYING);
  }

  // returns the chance of the given player winning if given this board state
  float getWinChance(boolean odd) {
   return odd ? stats.getOddChances() : stats.getEvenChances();
  }
  
  float getLossChance(boolean odd) {
     return odd ? stats.getEvenChances() : stats.getOddChances();
  }
  
  // heuristic uses linear interpolation between winrate and games played, based on confidence
  // it takes both the average of the nonlosing chance, and the win chance 
  float getHeuristic(boolean odd)
  {
    float wr_weight = ((float)stats.getNumGames()) / 50f;
    wr_weight = constrain(wr_weight, 0.0, 1.0);
    
    if(stats.getNumGames() == 0)
    {
      return 0.999;
    }
    
   // println(stats.getNumGames());
    // now the mathematical value for the nonloss heuristic is defined as 
    // (1 - loss chance) * wr_weight + 1.0 * (1 - wr_weight)
    float nonLossHeuristic = (1.0f - getLossChance(odd)) * wr_weight + (1.0f - wr_weight);
   
    // the math value for the win heuristic is defined as 
    // winChance * wr_weight + 1.0 * (1 - wr_weight)
    float winHeuristic = (float) getWinChance(odd) * wr_weight + (1.0f - wr_weight);
    
    float heuristic = (nonLossHeuristic + winHeuristic) / 2.0f;
    //println(nonLossHeuristic+ ", " + winHeuristic+ ", " + heuristic);
    return heuristic;
  }
  
  Board getChild(int row, int col) {
    if (this.tiling[row][col] != '0') {
      return null;
    }

    String s = "";

    for (int r=0; r<3; r++) {
      for (int c=0; c<3; c++) {
        if (r == row && c == col) {
          s += (char) (num_moves + 1 + '0');
        } else {
          s += tiling[r][c];
        }
      }
    }
    
    // get the board that's associated with this setup
    Board child = boards.get(s);

    return child;
  }

  // returns an array of win chances for spot choices
  // a spot has the values defined as follows
  // 2.0 if there isn't any data on this path
  // 1.0 if this move would win the game
  // [0.0, 1.0) if the move isn't instant win
  // -1.0 if this tile is already filled
  float[][] getChildWinChances(boolean odd) {
    float [][] arr = new float[3][3];

    Board child;
    for (int r=0; r<3; r++) {
      for (int c=0; c<3; c++) {
        child = this.getChild(r, c);
        if (child == null) {
          arr[r][c] = SPOT_TAKEN;
        } else {
          arr[r][c] = child.getWinChance(odd);
        }
      }
    }

    return arr;
  }

  // returns an array of loss chances for spot choices
  // a spot has the values defined as follows
  // 2.0 if there isn't any data on this path
  // 1.0 if this move would lose the game
  // [0.0, 1.0) if the move isn't instant loss
  // -1.0 if this tile is already filled
  float[][] getChildLossChances(boolean odd) {
    float [][] arr = new float[3][3];

    Board child;
    for (int r=0; r<3; r++) {
      for (int c=0; c<3; c++) {
        child = this.getChild(r, c);
        if (child == null) {
          arr[r][c] = SPOT_TAKEN;
        } else {
          arr[r][c] = child.getLossChance(odd);
          // the "unknown" value
          if(arr[r][c] == NO_DATA) {
            arr[r][c] = -2.0;
          }
        }
      }
    }

    return arr;
  }
  
  float[][] getChildHeuristic(boolean odd) {
    float [][] arr = new float[3][3];

    Board child;
    for (int r=0; r<3; r++) {
      for (int c=0; c<3; c++) {
        child = this.getChild(r, c);
        if (child == null) {
          arr[r][c] = SPOT_TAKEN;
        } else {
          arr[r][c] = child.getHeuristic(odd);
        }
      }
    }

    return arr;
  }

  void printout() {
    println();
    println("-------------");
    println("| " + tiling[0][0] + " | " + tiling[0][1] + " | " + tiling[0][2] + " |");
    println("| " + tiling[1][0] + " | " + tiling[1][1] + " | " + tiling[1][2] + " |");
    println("| " + tiling[2][0] + " | " + tiling[2][1] + " | " + tiling[2][2] + " |"); 
    println("-------------");
    switch(state) {
    case BOARD_PLAYING: 
      println("Waiting for turn.");
      break;
    case BOARD_EVEN_WIN:
      println("Second wins.");
      break;
    case BOARD_ODD_WIN:
      println("First wins.");
      break;
    case BOARD_TIE:
      println("Tie.");
      break;
    }
    println();
  }
}
