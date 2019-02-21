import React from "react";
import ReactDOM from "react-dom";
import _ from "lodash";

export default function game_init(root, channel, user) {
	ReactDOM.render(<Reversi channel={channel} user={user} />, root);
}

class Reversi extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      board: [],
      on_going: true,
      current_player: "black",
      players: [],
      spectators: []
    };
    this.user=props.user
    this.channel = props.channel; 
    this.channel.on("update", (game) => {
    this.setState(game);
    console.log("update");
    });
    this.channel
      .join()
      .receive("ok", this.init_state.bind(this))
      .receive("error", resp => {
        console.log(resp);
      });
  }

  init_state(props) {
    this.setState(props.game);
  }
  
  getPlayer(name) {
    for(var k in this.state.players) {
       if(this.state.players[k].name==name) {
         return k;
       }
    }
    return -1;
  }
  
  getSpectator(name) {
    for(var k in this.state.spectators) {
       if(this.state.spectators[k].name==name) {
         return k;
       }
    }
    return -1;
  }

  reset() {
   //only a player can reset the game
   if(this.getPlayer(this.user)>0) {
      this.channel.push("reset", {}).receive("ok", this.init_state.bind(this));
   }
  }
  
  leave() {
    var type="";
    //check if this user is a player
    console.log("leave");
    if(this.getPlayer(this.user)>=0) {
      type="player";
    }
    else {
      type="spectator";
    }
    this.channel.push("leave", {type: type, user: this.user})
    window.location.replace("http://127.0.0.1:4000")
  }

  click(x, y) {
    let idx = this.getPlayer(this.user);
    if(idx>=0) {
       if(this.state.players[idx].color==this.state.current_player) {
           this.channel.push("click", {x: x, y: y})
               .receive("ok", this.init_state.bind(this));
       }
    }
  }
  render() {
//     console.log(this.state.board)
     var len=this.state.players.length;
     var type = ((this.getPlayer(this.user)>0)? "player" : "spectator");
     return (
           <div> <h1>{len}</h1>
           <RenderBoard board={this.state.board} click={this.click.bind(this)} />
	   <button onClick={this.leave.bind(this)}>leave</button>
	   <button onClick={this.reset.bind(this)}>leave</button>
           </div>
     );
  }
}

function RenderBoard(props) {
   var result=[];
   for(var x in props.board) {
     var row=[];
     for(var y in props.board[x]) {
        var target=props.board[x][y];
        if(target.color=="black") {
           row.push(<button>B</button>)
        }
        else if(target.color=="white") {
           row.push(<button>W</button>)
        }
        else {
           let x_cp=x;
	   let y_cp=y;
           row.push(<button onClick={() => props.click(x_cp, y_cp)}> " " </button>)
        }
     }
      result.push(<p>{row}</p>)
   }
   return (
     <div>{result}</div>
   );
}

function RenderUserList(props) {
  let list=props.all;
  
}






