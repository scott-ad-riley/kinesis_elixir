# KinesisElixir

Playing around with Kinesis streams attempting to use GenStage to manage shards and process events

## Installation

1. `mix deps.get`
2. Setup your aws credentials in environment via `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
3. Add your stream name to `KINESIS_STREAM_NAME` env var
4. Make sure the region is set correctly in your config too (ireland -> `eu-west-1` and london -> `eu-west-2`)
