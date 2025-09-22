// Debug version - minimal gossip test
import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/otp/actor

@external(erlang, "erlang", "system_time")
fn erlang_system_time(unit: SystemTimeUnit) -> Int

pub type SystemTimeUnit {
  Millisecond
}

fn get_current_time_millis() -> Int {
  erlang_system_time(Millisecond)
}

pub type GossipState {
  GossipState(
    id: Int,
    neighbor: process.Subject(GossipMessage),
    rumor_count: Int,
  )
}

pub type GossipMessage {
  Rumor
  SetNeighbor(process.Subject(GossipMessage))
}

pub fn main() {
  let start_time = get_current_time_millis()

  // Create exactly 2 actors
  let assert Ok(actor0) =
    actor.new(GossipState(
      id: 0,
      neighbor: process.new_subject(),
      rumor_count: 0,
    ))
    |> actor.on_message(handle_message)
    |> actor.start()

  let assert Ok(actor1) =
    actor.new(GossipState(
      id: 1,
      neighbor: process.new_subject(),
      rumor_count: 0,
    ))
    |> actor.on_message(handle_message)
    |> actor.start()

  // Set them as each other's neighbors
  process.send(actor0.data, SetNeighbor(actor1.data))
  process.send(actor1.data, SetNeighbor(actor0.data))

  // Wait a moment for setup
  process.sleep(50)

  // Start gossip
  io.println("Starting gossip...")
  process.send(actor0.data, Rumor)

  // Wait and print result
  process.sleep(5000)
  // 5 seconds should be more than enough
  let elapsed = get_current_time_millis() - start_time
  io.println("Time: " <> int.to_string(elapsed))
}

fn handle_message(
  state: GossipState,
  message: GossipMessage,
) -> actor.Next(GossipState, GossipMessage) {
  case message {
    Rumor -> {
      let new_count = state.rumor_count + 1
      io.println(
        "Node "
        <> int.to_string(state.id)
        <> " heard rumor #"
        <> int.to_string(new_count),
      )

      case new_count < 10 {
        True -> {
          // Forward rumor to neighbor
          io.println("Node " <> int.to_string(state.id) <> " forwarding rumor")
          process.send(state.neighbor, Rumor)
          actor.continue(GossipState(..state, rumor_count: new_count))
        }
        False -> {
          io.println("Node " <> int.to_string(state.id) <> " CONVERGED!")
          actor.continue(GossipState(..state, rumor_count: new_count))
        }
      }
    }

    SetNeighbor(neighbor) -> {
      io.println("Node " <> int.to_string(state.id) <> " got neighbor")
      actor.continue(GossipState(..state, neighbor: neighbor))
    }
  }
}
