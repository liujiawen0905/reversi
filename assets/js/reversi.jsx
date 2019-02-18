import React from "react";
import ReactDOM from "react-dom";
import _ from "lodash";

export default function game_init(root, channel, user) {
	console.log(user);
	ReactDOM.render(<Reversi channel={channel} user={user} />, root);
}

class Reversi extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      user_name: props.user,
      board: [],
      on_going: true,
      current_player: "black",
      players: [],
      spectators: []
    };
    this.channel = props.channel;
    this.channel
      .join()
      .receive("ok", this.init_state.bind(this))
      .receive("error", resp => {
        console.log(resp);
      });
  }

  render() {
     console.log("render")
     return (
           <div> <h1>{this.user_name}</h1></div>
     )
  }
}
