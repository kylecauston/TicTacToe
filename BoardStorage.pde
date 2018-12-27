import java.util.Set;


class BoardStorage {
  HashMap<String, Board> board_map;
  Board root;
  
  BoardStorage() {
    board_map = new HashMap<String, Board>();
    root = null;
  }
  
  Board getRoot() { return root; }
  
  void put(String k, Board v) {
    board_map.put(k, v);
    if(v.toString().equals("000000000")) {
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
  
  String[] outputString() {
    String[] board_names = board_map.keySet().toArray(new String[1]);
    String[] output = new String[board_names.length];
    for(int i=0; i<board_names.length; i++) {
      output[i] = board_map.get(board_names[i]).toFileString();
    }
  
    return output;
  }
}
