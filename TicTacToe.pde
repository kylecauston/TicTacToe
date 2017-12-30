final int RED_PLAYER = 0;
final int BLUE_PLAYER = 1;

Board current_board;
int best_move;
AI bot;

int first_turn;
int current_turn;

float last_time;
float time_since_turn;

boolean auto = false;

void setup() {
  current_board = new Board();
  bot = new AI();
  
  best_move = bot.getMove();
  
  first_turn = BLUE_PLAYER;//(random(1.0) > 0.5) ? BLUE_PLAYER : RED_PLAYER;
  current_turn = first_turn;
 
  size(200,200);
  background(0);
  last_time = 0;
}

void draw() {
  background(#FFFFFF);
  drawBoard(current_board);
  
  float delta_time = millis() - last_time;
  last_time = millis();
  
  if(current_turn == RED_PLAYER || auto) {
    
    if (auto) delta_time *= 100;
    time_since_turn += delta_time;
    
    if(time_since_turn > 1*1000) {
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
  rect(0,0,width-1,height-1);
  
  // highlight the best move for next turn
  if(current_turn == RED_PLAYER) {
    stroke(#FF0000);
  } else {
    stroke(#1000FF);
  }
  
  int row = best_move / 3;
  int col = best_move % 3;
  strokeWeight(2);
  rect(col*(width/3)+1, row*(height/3)+1, (width/3)-1, (height/3)-1);
  strokeWeight(1);
  
  int tile;
  for(int r=0; r<3; r++) {
    for(int c=0; c<3; c++) {
      tile = b.tiling[r][c];
      if(tile != 'E') { // there is a piece here
        if(tile == '2') { // even
          if(first_turn == RED_PLAYER) { // if red went first, blue is odd
            fill(#1000FF);
          } else {
            fill(#FF0000);
          }
        } else { // odd
          if(first_turn == RED_PLAYER) { // if red went first, blue is odd
            fill(#FF0000);
          } else {
            fill(#1000FF);
          }
        }
      
        noStroke();
        ellipse((c+1) * (width/3) - width/6, (r+1)*(height/3) - height/6, 15, 15);
      }
    }
  }
}

void inputTurn(int r, int c) {
  if(current_board.getChild(r,c) != null) {
    current_board = current_board.getChild(r, c);
    current_turn = (current_turn == RED_PLAYER) ? BLUE_PLAYER : RED_PLAYER;
 
    if(current_board.isDone()) {
      current_board.printout();
      resetGame();
    }
  } 
  
  best_move = bot.getMove();
}

void resetGame() {
  int end_state = current_board.state;
  
  while(current_board.parent != null) {
    switch(end_state) {
      case BOARD_EVEN_WIN:
        current_board.even_victories++;
        break;
      case BOARD_ODD_WIN:
        current_board.odd_victories++;
        break;
    }
    
    current_board.child_games++;
    current_board = current_board.parent;
  }
  
  first_turn = (random(1.0) > 0.5) ? BLUE_PLAYER : RED_PLAYER;
  current_turn = first_turn;
  best_move = bot.getMove();
}

void mousePressed() { 
  if(mouseButton == RIGHT) {
   // current_board = current_board.parent;
   // return;
  }
  
  int c = mouseX/(width/3);
  int r = mouseY/(height/3);
  
  inputTurn(r,c);
}

void keyPressed() {
  if(key == 'n') {
    inputTurn(best_move / 3, best_move % 3);
  } else if (key == 'c') {
    float[][] chances = current_board.getWinChances();
    current_board.printout();
    
    println("Win Chances");
    for(int r=0; r<3; r++) {
      println();
      for(int c=0; c<3; c++) {
       print(" " + chances[r][c] + " ");
      }
    }
    
    float[][] loss_chance = current_board.getLossChances();
    
    println();
    println("Loss Chances");
    for(int r=0; r<3; r++) {
      println();
      for(int c=0; c<3; c++) {
       print(" " + loss_chance[r][c] + " ");
      }
    }
  } else {
    auto = !auto;
  }
}