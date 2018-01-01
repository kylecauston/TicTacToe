import java.util.HashMap; //<>//

final int BOARD_PLAYING = 0;
final int BOARD_ODD_WIN = 1;
final int BOARD_EVEN_WIN = 2;
final int BOARD_TIE = 3;

final char BLUE_TOKEN = 'B';
final char RED_TOKEN = 'R';

class Board {  
  char[][] tiling;

  int state = BOARD_PLAYING;

  int num_moves = 0;

  // keep track of the victories of children
  int child_games = 0;
  int odd_victories = 0;
  int even_victories = 0;

  Board() {
    tiling = new char[3][3];

    for (int r=0; r<3; r++) {
      for (int c=0; c<3; c++) {
        tiling[r][c] = 'E';
      }
    }
    
    boards.put("EEEEEEEEE", this);
  }

  Board(String s) {
    tiling = new char[3][3];
    num_moves = 0;

    for (int r=0; r<3; r++) {
      for (int c=0; c<3; c++) {
        tiling[r][c] = s.charAt(r*3 + c);

        if (tiling[r][c] != 'E') num_moves++;
      }
    }

    // now set state

    // first check if the row was a victory
    boolean row_victory = false;
    boolean col_victory = false;
    boolean down_right_victory = false;
    boolean down_left_victory = false;

    // t represents which player we're looking for (p1 or 2)
    for (int t=1; t<3; t++) {              
      char tile = (t == 1) ? '1' : '2';

      for (int r=0; r<3; r++) {
        row_victory = row_victory
          || tiling[r][0] == tile
          && tiling[r][1] == tile
          && tiling[r][2] == tile;
      }

      for (int c=0; c<3; c++) {
        col_victory = col_victory
          || tiling[0][c] == tile
          && tiling[1][c] == tile
          && tiling[2][c] == tile;
      }

      down_right_victory = tiling[0][0] == tile
        && tiling[1][1] == tile
        && tiling[2][2] == tile;

      down_left_victory = tiling[0][2] == tile
        && tiling[1][1] == tile
        && tiling[2][0] == tile;
        
      if (row_victory || col_victory || down_right_victory || down_left_victory) {
        state = (tile == '1') ? BOARD_ODD_WIN : BOARD_EVEN_WIN;
        break;
      } else if (num_moves == 9) {
        state = BOARD_TIE;
        break;
      }
    }
    
    boards.put(s, this);
  }

  Board(char[][] prev_board, int r, int c, boolean player_one) {
    this();

    String s = "";
    num_moves = 0;

    for (int R=0; R<3; R++) {
      for (int C=0; C<3; C++) {
        if (R == r && C == c) 
        {
          tiling[r][c] = player_one ? '1' : '2';
        } else { 
          tiling[R][C] = prev_board[R][C];
        }

        if (tiling[R][C] != 'E') num_moves++;
        s += tiling[R][C];
      }
    }

    // set state by checking things that the new tile could have affected

    // check what type of victory we look for (player 1 or 2)
    char tile = player_one ? '1' : '2';

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


    // if this is a victory state, pick the correct state
    // if it's not victory state, check if it's a tie
    if (row_victory || col_victory || down_right_victory || down_left_victory) {
      state = (tile == '1') ? BOARD_ODD_WIN : BOARD_EVEN_WIN;
    } else if (num_moves == 9) {
      state = BOARD_TIE;
    }

    boards.put(s, this);
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

  // returns the chance of the given player winning
  float getWinChance(boolean player_one) {
    if (child_games > 0) {
      return player_one ? ((float) odd_victories) / child_games : ((float) even_victories) / child_games;
    } else {
      return 2.0f;
    }
  }

  float getLossChance(boolean player_one) {
    if (child_games > 0) {
      return player_one ? ((float) even_victories) / child_games : ((float) odd_victories) / child_games;
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
  float[][] getWinChances(boolean player_one) {
    float [][] arr = new float[3][3];

    Board child;
    for (int r=0; r<3; r++) {
      for (int c=0; c<3; c++) {
        child = this.getChild(r, c, player_one);
        if (child == null) {
          arr[r][c] = -1.0;
        } else {
          arr[r][c] = child.getWinChance(player_one);
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
  float[][] getLossChances(boolean player_one) {
    float [][] arr = new float[3][3];

    Board child;
    for (int r=0; r<3; r++) {
      for (int c=0; c<3; c++) {
        child = this.getChild(r, c, player_one);
        if (child == null) {
          arr[r][c] = -1.0;
        } else {
          arr[r][c] = child.getLossChance(player_one);
        }
      }
    }

    return arr;
  }

  Board getChild(int row, int col, boolean player_one) {
    if (this.tiling[row][col] != 'E') {
      return null;
    }

    String s = "";

    for (int r=0; r<3; r++) {
      for (int c=0; c<3; c++) {
        if (r == row && c == col) {
          s += player_one ? '1' : '2';
        } else {
          s += tiling[r][c];
        }
      }
    }

    // get the board that's associated with this setup
    Board child = boards.get(s);

    return child;
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