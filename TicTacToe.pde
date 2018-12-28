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

// not sure where else to put this. used for
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

  size(400, 400);
  background(0);
  last_time = 0;
}

void draw() {
  background(#FFFFFF);
  drawBoard(current_board);

  //stop();
  float delta_time = millis() - last_time;
  last_time = millis();

  if (current_turn == RED_PLAYER) {

    if(auto) time_since_turn += delta_time;

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

  float[][] loss_chances = current_board.getChildLossChances(current_turn == first_turn);
  float[][] win_chances = current_board.getChildWinChances(current_turn == first_turn);
  float[][] heuristic = current_board.getChildHeuristic(current_turn == first_turn);
  
  int tile;
  for (int r=0; r<3; r++) {
    for (int c=0; c<3; c++) {
      tile = Character.getNumericValue(b.tiling[r][c]);
      if (tile != 0) {
        if (tile % 2 == 0) { // even
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
      }
      if (tile != 0) { // there is a piece here
        noStroke();
        ellipse((c+1) * (width/3) - width/6, (r+1)*(height/3) - height/6, 15, 15);
      } else { 
        textAlign(CENTER, CENTER);
        fill(#000000);
        text((heuristic[r][c]), (c+1) * (width/3) - width/6, (r+1)*(height/3) - height/6 - 10);
        //fill(#5FFF21);
        //text((int)(win_chances[r][c]*100)+"%", (c+1) * (width/3) - width/6, (r+1)*(height/3) - height/6 - 10);
        //fill(#FF4D4D);
        //text((int)(loss_chances[r][c]*100)+"%", (c+1) * (width/3) - width/6, (r+1)*(height/3) - height/6 + 10);
      }
    }
  }
}

void inputTurn(int r, int c) {
  if (current_board.getChild(r, c) != null) {
    current_board = current_board.getChild(r, c);
    current_turn = (current_turn == RED_PLAYER) ? BLUE_PLAYER : RED_PLAYER;
    
    if (current_board.isDone()) {
      current_board.printout();
      resetGame();
    }
  } 

  best_move = bot.getMove();
  
  current_board.printout();
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

Board rotateBoard(Board b) 
{
  char[][] transpose = new char[3][3];
  
  // find the transpose
  for(int r=0; r<3; r++)
  {
    for(int c=0; c<3; c++)
    {
      transpose[c][r] = b.tiling[r][c];
    }
  }
  
  // reverse the columns
  int col = 0;
  char[][] newBoardData = new char[3][3];
  for(int c=2; c>=0; c--)
  {
    for(int r=0; r<3; r++)
    {
      newBoardData[r][c] = transpose[r][col];
    }
    col++;
  }

  String s = "";
  for(int r=0; r<3; r++)
  {
    for(int c=0; c<3; c++)
    {
      s += newBoardData[r][c];
    }
  }
  
  return boards.get(s);
}

void saveGame() {
  // reset our set of visited boards
  visited_boards.clear();
  
  // get all 4 versions of the board (rotated)
  saveGame_rec(current_board, current_board.state);
  
  Board r90 = rotateBoard(current_board);
  visited_boards.clear();
  saveGame_rec(r90, r90.state);
  
  Board r180 = rotateBoard(r90);
  visited_boards.clear();
  saveGame_rec(r180, r180.state);
  
  Board r270 = rotateBoard(r180);
  visited_boards.clear();
  saveGame_rec(r270, r270.state);
}

// recursive function for saving end state to all parent boards
void saveGame_rec(Board ob, int end_state) {
  // get string for original board
  String board_string = ob.toString();
  
  Board b;
  // add the end state to each of the boards that led to this board
  for(int i=9; i>=0; i--)
  {
    b = boards.get(board_string);
    if(!visited_boards.contains(board_string)) {
      visited_boards.add(board_string);
    
      // increment b stats based on end_state
      if (end_state == BOARD_EVEN_WIN) { 
        println("adding even win to " + board_string);
        b.addVictory(true);
      } else if (end_state == BOARD_ODD_WIN) {
        println("adding odd win to " + board_string);
        b.addVictory(false);
      } else if (end_state == BOARD_TIE) {
        println("adding tie to " + board_string);
        b.addTie();
      } else {
        println("adding nothing to " + board_string); 
      }
    }
    
    board_string = board_string.replace((char) (i+'0'), '0');
  }
}

void resetGame() {
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
  
    
    current_board = boards.getRoot();
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
    float[][] chances = current_board.getChildWinChances(current_turn == first_turn);
    current_board.printout();

    println("Win Chances");
    for (int r=0; r<3; r++) {
      println();
      for (int c=0; c<3; c++) {
        print(" " + chances[r][c] + " ");
      }
    }

    float[][] loss_chance = current_board.getChildLossChances(current_turn == first_turn);

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
    println("auto: " + auto);
  }
}

void exit() {
  recordLearnedData();
}
