# KinesisElixir

Playing around with Kinesis streams attempting to use GenStage to manage shards and process events

## Installation

1. `mix deps.get`
2. Setup your aws credentials in environment via `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
3. Add your stream name to `KINESIS_STREAM_NAME` env var
4. Make sure the region is set correctly in your config too (ireland -> `eu-west-1` and london -> `eu-west-2`)

## Stuff to fix

1. Process naming - where/when/why do I need dynamic process names/identifiers
    * `KinesisElixir.StreamSupervisor.map_to_child_specs/1` is pretty horrendous and I'm pretty certain I'm doing something wrong
    * `KinesisElixir.ShardIterator.name/1` is also pretty horrendous (but not as bad...?)
2. Adding limiting/custom demand values
3. Better handling/restarting of the iterator processes if kinesis blows up (like the read throughput exception)
4. Tests
    * Ideally that don't use a real kinesis stream (probably pass in a module in that behaves like one)

## Notes

**TURN THE KINESIS STREAM OFF IF YOU'RE NOT USING IT**

### Buffering Demand

So in the case where a producer receives demand for X events (let's say 1000) and it cannot provide that demand immediately/synchronously you have to buffer that demand and give events back to the consumer as they come in.

Most examples on the internet for `GenStage` have producers that can provide potentially infinite events, without delay which made this quite tricky to figure out.

After discovering that you can dispatch events if you `cast` to a `GenStage` producer, what I've implemented is a recursive `cast`ing call whenever there is buffered demand.

The example in the elixir docs has a `Broadcaster` which implements a different solution to the buffering problem but it requires you to call `sync_notify` on your producer to tell it when to fetch events (it's not recursively checking). I preferred the recursive check because it seemed to fit better with Kinesis' pull-based nature.

There's a limit in the recursive `cast`ing that's fairly naively implemented with a `Process.sleep(200)` because Kinesis won't let you read/`get_records` more than 5 times a second (per shard).
