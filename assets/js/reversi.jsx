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
     console.log("render")
     return (
           <div> <h1>{this.user}</h1>
           <RenderBoard board={this.state.board} click={this.click.bind(this)} />
           </div>
     );
  }
}

function RenderBoard(props) {
   var result=[];
   for(var x in props.board) {
     var row=[];
     for(var y in props.board[x]) {
        var target=props.board[y][x];
        if(target.color=="black") {
           row.push(<button>B</button>)
        }
        if(target.color=="white") {
           row.push(<button>W</button>)
        }
        else {
           row.push(<button onClick={() => props.click(x, y)}> " " </button>)
        }
     }
      result.push(<span>{row}</span>)
   }
   return (
     <div>{result}</div>
   );
}

