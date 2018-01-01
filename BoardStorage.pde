
class BoardStorage {
  HashMap<String, Board> board_map; ;
  Board root;
  
  BoardStorage() {
    board_map = new HashMap<String, Board>();
    root = null;
  }
  
  Board getRoot() { return root; }
  
  void put(String k, Board v) {
    board_map.put(k, v);
    if(v.toString().equals("EEEEEEEEE")) {
      root = v;
    }
  }
  
  Board get(String k) {
    Board b = board_map.get(k);
    
    // if we haven't seen this board yet it won't be in the
    // map. so we need to make a new board based on the key
    if(b == null) {
      return (new Board(k));
    }
    
    return b;
  }
}