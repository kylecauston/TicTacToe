import java.util.HashSet;

final int RED_PLAYER = 0;
final int BLUE_PLAYER = 1;

Board current_board;
int best_move;
AI bot;

int first_turn;
int current_turn;

float last_time;
float time_since_turn;

BoardStorage boards;

// not sure where else to put this used for
// recording results, so we don't assign a
// win to a board multiple times
HashSet<String> visited_boards;

boolean auto = false;

void setup() {
  boards = new BoardStorage();

  if(!loadRecordedData()) {
    current_board = new Board();
  }
  
  bot = new AI();

  visited_boards = new HashSet();

  best_move = bot.getMove();

  first_turn = (random(1.0) > 0.5) ? BLUE_PLAYER : RED_PLAYER;
  current_turn = first_turn;

  size(200, 200);
  background(0);
  last_time = 0;
}

void draw() {
  background(#FFFFFF);
  drawBoard(current_board);

  float delta_time = millis() - last_time;
  last_time = millis();

  if (current_turn == RED_PLAYER || auto) {

    if (auto) delta_time *= 100;
    //time_since_turn += delta_time;

    if (time_since_turn > 1*1000) {
      inputTurn(best_move / 3, best_move % 3);

      time_since_turn = 0;
    }
  }
}

void drawBoard(Board b) {

  stroke(0);
  strokeWeight(1);
  line(width/3, 0, width/3, height);
  line(2*width/3, 0, 2*width/3, height);

  line(0, height/3, width, height/3);
  line(0, 2*height/3, width, 2*height/3);

  noFill();
  rect(0, 0, width-1, height-1);

  // highlight the best move for next turn
  if (current_turn == RED_PLAYER) {
    stroke(#FF0000);
  } else {
    stroke(#1000FF);
  }

  int row = best_move / 3;
  int col = best_move % 3;
  strokeWeight(2);
  rect(col*(width/3)+1, row*(height/3)+1, (width/3)-1, (height/3)-1);
  strokeWeight(1);

  float[][] chances = current_board.getLossChances(current_turn == first_turn);

  int tile;
  for (int r=0; r<3; r++) {
    for (int c=0; c<3; c++) {
      tile = b.tiling[r][c];
      if (tile == '2') { // even
        if (first_turn == RED_PLAYER) { // if red went first, blue is odd
          fill(#1000FF);
        } else {
          fill(#FF0000);
        }
      } else { // odd
        if (first_turn == RED_PLAYER) { // if red went first, blue is odd
          fill(#FF0000);
        } else {
          fill(#1000FF);
        }
      }
      if (tile != 'E') { // there is a piece here
        noStroke();
        ellipse((c+1) * (width/3) - width/6, (r+1)*(height/3) - height/6, 15, 15);
      } else { 
        textAlign(CENTER, CENTER);
        fill(#000000);
        text((int)(chances[r][c]*100)+"%", (c+1) * (width/3) - width/6, (r+1)*(height/3) - height/6);
      }
    }
  }
}

void inputTurn(int r, int c) {
  if (current_board.getChild(r, c, current_turn == first_turn) != null) {
    current_board = current_board.getChild(r, c, current_turn == first_turn);
    current_turn = (current_turn == RED_PLAYER) ? BLUE_PLAYER : RED_PLAYER;

    if (current_board.isDone()) {
      current_board.printout();
      resetGame();
    }
  } 

  best_move = bot.getMove();
}

ArrayList<Integer> indexOfMultiple(String s, char c) {
  ArrayList<Integer> indices = new ArrayList<Integer>();
  String temp_string = new String(s);

  int offset = 0;
  int i = 0;
  while (temp_string.indexOf(c) != -1) {
    i = temp_string.indexOf(c);
    indices.add(i + offset);
    // now we want to get the substring after the index, store 
    // how much offset we've creating by shrinking the string
    offset += i + 1;
    temp_string = temp_string.substring(i + 1);
  }

  return indices;
}

void saveGame() {
  // reset our set of visited boards
  visited_boards.clear();
  
  // pass in the current board, whether the last player was p1, and the end state
  saveGame_rec(current_board, !(current_turn == first_turn), current_board.state);
}

// recursive function for saving end state to all parent boards
void saveGame_rec(Board b, boolean player_one, int end_state) {
  // get string for b
  String board_string = b.toString();
  
  char board_piece = player_one? '1' : '2';

  // base case:
  // if board is not start state (EEEEEEEEE),
  if (!board_string.equals("EEEEEEEEE")) {
    // find all indices of cur player (1 or 2) in string
    ArrayList<Integer> indices = indexOfMultiple(board_string, board_piece);

    // call this on each index one by one, replacing with E
    String new_string;
    for (Integer i : indices) {
      // build the string:
      new_string = "";

      // if there's anything before the index, add it
      if (i > 0) new_string += board_string.substring(0, i);

      // add the E that replaces the index
      new_string += 'E';

      // now add the remaining board
      if (i+1 < board_string.length()) new_string += board_string.substring(i+1);

      // now recurse on these boards
      saveGame_rec(boards.get(new_string), !player_one, end_state);
    }
  }

  if(!visited_boards.contains(board_string)) {
    visited_boards.add(board_string);
    // increment b stats based on end_state
    if (end_state == BOARD_EVEN_WIN) { 
      b.addVictory(true);
    } else if (end_state == BOARD_ODD_WIN) {
      b.addVictory(false);
    } else if (end_state == BOARD_TIE) {
      b.addTie();
    }
  }
}

void resetGame() {
  int end_state = current_board.state;

  saveGame();

  current_board = boards.getRoot();

  first_turn = (random(1.0) > 0.5) ? BLUE_PLAYER : RED_PLAYER;
  current_turn = first_turn;
  best_move = bot.getMove();
}

void recordLearnedData() {
  // take what the bot has learned about the boards and save to memory
  saveStrings("data/memory.txt", boards.outputString());
}

boolean loadRecordedData() {
  File memory = dataFile("memory.txt");
  
  if(memory.exists()) {
    String[] lines = loadStrings("data/memory.txt"); 
    
    String[] parts;
    for(int i=0; i<lines.length; i++) {
      parts = split(lines[i], ":");
      
      boards.get(parts[0]).setStatistic(new Statistic(parts[1]));
    }
  
    
    current_board = boards.get("EEEEEEEEE");
    return true;
  } 
  
  return false;
}

void mousePressed() { 
  if (mouseButton == RIGHT) {
    // current_board = current_board.parent;
    recordLearnedData();
    return;
  }

  int c = mouseX/(width/3);
  int r = mouseY/(height/3);

  inputTurn(r, c);
}

void keyPressed() {
  if (key == 'n') {
    inputTurn(best_move / 3, best_move % 3);
  } else if (key == 'c') {
    float[][] chances = current_board.getWinChances(current_turn == first_turn);
    current_board.printout();

    println("Win Chances");
    for (int r=0; r<3; r++) {
      println();
      for (int c=0; c<3; c++) {
        print(" " + chances[r][c] + " ");
      }
    }

    float[][] loss_chance = current_board.getLossChances(current_turn == first_turn);

    println();
    println("Loss Chances");
    for (int r=0; r<3; r++) {
      println();
      for (int c=0; c<3; c++) {
        print(" " + loss_chance[r][c] + " ");
      }
    }
    
    println(current_board.stats.getOddWins());
  } else {
    auto = !auto;
  }
}

void exit() {
  recordLearnedData();
}