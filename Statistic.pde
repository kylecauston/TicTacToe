
class Statistic { 
  private int num_games = 0;
  private int odd_wins = 0;
  private int even_wins = 0;
  
  Statistic() {
    
  }
  
  Statistic(String s) {
    String[] split = s.split("|");
    num_games = parseInt(split[0]);
    odd_wins = parseInt(split[1]);
    even_wins = parseInt(split[2]);  
  }
  
  float getConfidence() {
    return max(1.0, num_games / 10.0f);
  }
  
  int getOddWins() { return odd_wins; } 
  
  int getEvenWins() { return even_wins; }
  
  int getNumGames() {
    return num_games;
  }
  
  float getOddChances() {
    if(num_games <= 0) return 2.0;
    
    return ((float) odd_wins) / num_games;
  }
  
  float getEvenChances() {
    if(num_games <= 0) return 2.0;
    
    return ((float) even_wins) / num_games;
  }
 
  float getTieChances() {
    if(num_games <= 0) return 2.0;
    
    int ties = (num_games - odd_wins - even_wins);
    return ((float) ties) / num_games;
  }
  
  @Override
  String toString() {
    return (num_games + "|" + odd_wins + "|" + even_wins);
  }
  
  void addResult(boolean even_victory) {
    if(even_victory) {
      even_wins++;
    } else {
      odd_wins++;
    }
    num_games++;
  }
  
  void addTie() {
    num_games++;
  }
}