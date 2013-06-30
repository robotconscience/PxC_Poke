import spacebrew.*;
import java.util.Map;

String server="10.200.82.197";
String name="Poke Server";
String description ="";

Spacebrew sb;

// map of players to hits
HashMap<String,Integer> playerMap = new HashMap<String,Integer>();

void setup() {
    size(200, 200);
    // instantiate the sb variable
    sb = new Spacebrew( this );

    // add each thing you publish to
    sb.addPublish( "startGame", "boolean", false ); 
    sb.addPublish( "endGame", "boolean", false ); 
    sb.addPublish( "poke", "boolean", true );

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
    playerMap.put( value, 0 );
    if ( playerMap.size() > 1 ){
      sb.send("startGame", true );
    }
  } else if ( name.equals("playerExit") ) {
    playerMap.remove( value );
    sb.send("endGame", true );
  } else if ( name.equals("poke" ) ){
    println( "Player "+name+" poked "+ playerMap.get( name ) + 1 );
    int val =  playerMap.get( name );
    val++;
    playerMap.put( name, val );
  }
}

void onCustomMessage( String name, String type, String value ){
	println("got " + type + " message " + name + " : " + value);  
}
