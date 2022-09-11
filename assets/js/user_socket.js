// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// Bring in Phoenix channels client library:
import { Socket } from "phoenix";

// And connect to the path in "lib/chat_web/endpoint.ex". We pass the
// token for authentication. Read below how it should be used.
let socket = new Socket("/socket", { params: { token: window.userToken } });

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/chat_web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/chat_web/templates/layout/app.html.heex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/3" function
// in "lib/chat_web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket, _connect_info) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1_209_600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, connect to the socket:
socket.connect();

// Now that you are connected, you can join channels with a topic.
// Let's assume you have a channel with a topic named `room` and the
// subtopic is its id - in this case 42:
let channel = socket.channel("room:lobby", {});
channel.on("shout", function (payload) {
  // listen to the 'shout' event
  let li = document.createElement("li"); // create new list item DOM element
  let name = payload.name || "guest"; // get name from payload or set default
  li.innerHTML = "<b>" + name + "</b>: " + payload.message; // set li contents
  ul.appendChild(li); // append to list
});

channel.join();

let ul = document.getElementById("msg-list"); // list of messages.
let name = document.getElementById("name"); // name of message sender
let msg = document.getElementById("msg-static"); // message input field

// "listen" for the [Enter] keypress event to send a message:
msg?.addEventListener("keypress", function (event) {
  if (event.keyCode == 13 && msg.value.length > 0) {
    // don't sent empty msg.
    channel.push("shout", {
      // send the message to the server on "shout" channel
      name: name.value || "guest", // get value of "name" of person sending the message. Set guest as default
      message: msg.value, // get message text (value) from msg input field.
    });
    msg.value = ""; // reset the message input field for next message.
  }
});

export default socket;
