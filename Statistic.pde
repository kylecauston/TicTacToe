
class Statistic { 
  private int num_games = 0;
  private int odd_wins = 0;
  private int even_wins = 0;
  
  Statistic() {
    
  }
  
  Statistic(String s) {
    String[] parts = split(s, "|");
    num_games = parseInt(parts[0]);
    odd_wins = parseInt(parts[1]);
    even_wins = parseInt(parts[2]);
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
    if(num_games <= 0) return NO_DATA;
    
    return ((float) odd_wins) / num_games;
  }
  
  float getEvenChances() {
    if(num_games <= 0) return NO_DATA;
    
    return ((float) even_wins) / num_games;
  }
 
  float getTieChances() {
    if(num_games <= 0) return NO_DATA;
    
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
    
    println("games: " + num_games + ", even: " + even_wins + ", odd: " + odd_wins);
  }
  
  void addTie() {
    num_games++;
  }
}
