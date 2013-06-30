import spacebrew.*;
import java.util.Map;
import java.util.Iterator;

String server="10.200.82.197";
String name="Poke Server";
String description ="";

Spacebrew sb;

// map of players to hits
HashMap<String,Player> playerMap = new HashMap<String,Player>();

int playerCount = 0;

void setup() {
    size(200, 200);
    // instantiate the sb variable
    sb = new Spacebrew( this );

    // add each thing you publish to
    sb.addPublish( "startGame", "boolean", false ); 
    sb.addPublish( "endGame", "boolean", false ); 
    sb.addPublish( "pokePlayer1", "range", 0 );
    sb.addPublish( "pokePlayer2", "range", 0 );
    sb.addPublish( "gameMessage", "string", "");

    // add each thing you subscribe to
    sb.addSubscribe( "playerReady", "string" );
    sb.addSubscribe( "playerExit", "string" );
    sb.addSubscribe( "poke", "string" );
    
    // connect to spacebrew
    sb.connect(server, name, description );
}

void draw() {
}

void onRangeMessage( String name, int value ){}

void onBooleanMessage( String name, boolean value ){}

void onStringMessage( String name, String value ){
  if ( name.equals("playerReady") ){
    Player player = new Player();
    player.index = value.indexOf("1") > 0 ? 1 : 2;
    //println("Name: "+value+", index: "+ player.index);
    
    playerMap.put( value, player );
    if ( playerMap.size() > 1 && playerCount != playerMap.size() ){
      sb.send("startGame", true );
    }
    playerCount = playerMap.size();
  } else if ( name.equals("playerExit") ) {
    playerMap.remove( value );
    playerMap.clear();
    sb.send("endGame", true );
    
  } else if ( name.equals("poke" ) ){
    // sending val as name:poke (poke = 0: left, 1:right)
    String[] vals = value.split(":");
    
    println( vals.length +" VALUES?");
    println( vals[0] );
    
    String pokeSource = vals[0]; // where poke came from
    int    pokeType   = int(vals[1]);
    
    Iterator it = playerMap.entrySet().iterator();
    while (it.hasNext()) {
        Map.Entry pairs = (Map.Entry)it.next();
//        System.out.println(pairs.getKey() + " = " + pairs.getValue());
        // should only be 2 players, so return once we find
        //  the other one
        String n = (String) pairs.getKey();
        if ( !pairs.getKey().equals(pokeSource) ){
          Player p = (Player) pairs.getValue();
          if ( pokeType == 0 ){
            p.hitCountLeft++;
          } else if ( pokeType == 1 ){
            p.hitCountRight++;
          }
          
          if ( p.hitCountLeft + p.hitCountRight >= 10 ){
            sb.send("gameMessage", n);
            sb.send("endGame", true );
            
            println("GAMMMMMEEEE OVERRRRR");
            
          } else {
            if ( p.index == 1 ){
              println("poked player 2");
              sb.send("pokePlayer2", pokeType );
            } else {
              println("poked player 1");
              sb.send("pokePlayer1", pokeType );
            }
          }
          break;
        }
    }
  }
}

void onCustomMessage( String name, String type, String value ){
	println("got " + type + " message " + name + " : " + value);  
}
