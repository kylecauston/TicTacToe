import java.util.HashMap;

final int BOARD_PLAYING = 0;
final int BOARD_ODD_WIN = 1;
final int BOARD_EVEN_WIN = 2;
final int BOARD_TIE = 3;

final char BLUE_TOKEN = 'B';
final char RED_TOKEN = 'R';

// originally static protected  
// this has to be out here because Processing is dumb (or I am)
HashMap<String, Board> board_map = new HashMap<String, Board>();

class Board {  
  char[][] tiling;
  
  int state = BOARD_PLAYING;
  
  Board[][] children;
  Board parent;
  
  boolean even_turn;
  int num_moves = 0;
  
  // keep track of the victories of children
  int child_games = 0;
  int odd_victories = 0;
  int even_victories = 0;
  
  Board() {
    parent = null;
    
    even_turn = false;
    
    tiling = new char[3][3];
    children = new Board[3][3];
    
    for(int r=0; r<3; r++) {
      for(int c=0; c<3; c++) {
        tiling[r][c] = 'E';
        children[r][c] = null;
      }
    }
  }
    
  Board(Board par, int r, int c) {
    this();
    
    parent = par;
    
    even_turn = !parent.even_turn;
    
    for(int R=0; R<3; R++) {
      for(int C=0; C<3; C++) {
        tiling[R][C] = parent.tiling[R][C];
      }
    }
    
    tiling[r][c] = (parent.even_turn) ? '2' : '1';
    
    num_moves = parent.num_moves + 1;
    
    // check things that the new tile could have affected
    
    // check what type of victory we look for (odd = 1 or even = 0)
    char tile = parent.even_turn ? '2' : '1';
    
    // first check if the row was a victory
    boolean row_victory = tiling[r][0] != 'E' && tiling[r][0] == tile
                            && tiling[r][1] != 'E' && tiling[r][1] == tile
                            && tiling[r][2] != 'E' && tiling[r][2] == tile;
                         
    // check if column was victory
    boolean col_victory = tiling[0][c] != 'E' && tiling[0][c] == tile
                  && tiling[1][c] != 'E' && tiling[1][c] == tile
                  && tiling[2][c] != 'E' && tiling[2][c] == tile;
                  
    // now check if either diagonal is applicable 
    boolean down_right_victory = r == c 
                  && tiling[0][0] != 'E' && tiling[0][0] == tile
                  && tiling[1][1] != 'E' && tiling[1][1] == tile
                  && tiling[2][2] != 'E' && tiling[2][2] == tile;
                                           
    boolean down_left_victory = r+c == 2 
                  && tiling[0][2] != 'E' && tiling[0][2] == tile
                  && tiling[1][1] != 'E' && tiling[1][1] == tile
                  && tiling[2][0] != 'E' && tiling[2][0] == tile;
    
    
    // if this is a victory BOARD, pick the correct BOARD
    // if it's not victory BOARD, check if it's a tie
    if(row_victory || col_victory || down_right_victory || down_left_victory) {
      state = (tile == '1') ? BOARD_ODD_WIN : BOARD_EVEN_WIN;
    } else if(num_moves == 9) {
      state = BOARD_TIE;
    }
    
    board_map.put(this.toString(), this);
  }
  
  String toString() {
    String s = "";
    
    for(int r=0; r<3; r++) {
      for(int c=0; c<3; c++) {
        s += this.tiling[r][c];
      }
    }
    
    return s;
  }
  
  boolean isDone() {
    return !(state == BOARD_PLAYING);
  }
  
  // returns the chance of the last player winning
  float getWinChance() {
    // not this turn but the last turn
    boolean last_even = !even_turn;
    
    if(child_games > 0) {
      return last_even ? ((float) even_victories) / child_games : ((float) odd_victories) / child_games;
    } else {
      return 2.0f;
    }
  }
  
  float getLossChance() {
    boolean last_even = !even_turn;
    
    if(child_games > 0) {
      return last_even ? ((float) odd_victories) / child_games : ((float) even_victories) / child_games;
    } else {
      return 0.0f;
    }
  }
  
  // returns an array of win chances for spot choices
  // a spot has the values defined as follows
  // 2.0 if there isn't any data on this path
  // 1.0 if this move would win the game
  // [0.0, 1.0) if the move isn't instant win
  // -1.0 if this tile is already filled
  float[][] getWinChances() {
    float [][] arr = new float[3][3];
    
    Board child;
    for(int r=0; r<3; r++) {
      for(int c=0; c<3; c++) {
        child = this.getChild(r,c);
        if(child == null) {
          arr[r][c] = -1.0;
        } else {
          arr[r][c] = child.getWinChance();
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
  float[][] getLossChances() {
    float [][] arr = new float[3][3];
    
    Board child;
    for(int r=0; r<3; r++) {
      for(int c=0; c<3; c++) {
        child = this.getChild(r,c);
        if(child == null) {
          arr[r][c] = -1.0;
        } else {
          arr[r][c] = child.getLossChance();
        }
      }
    }
    
    return arr;
  }
  
  Board getChild(int row, int col) {
    if(this.tiling[row][col] != 'E') { //<>//
      return null;
    }
    
    if(this.children[row][col] == null) {
      children[row][col] = new Board(this, row, col);
    }
   
    return children[row][col];
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
        println("Blue wins.");
        break;
      case BOARD_ODD_WIN:
        println("Red wins.");
        break;
      case BOARD_TIE:
        println("Tie.");
        break;
    }
    println();
  }
}