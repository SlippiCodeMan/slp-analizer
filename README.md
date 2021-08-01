# Slp Analyzer

## Api

> The port used for websocket is **9003**.

### Client messages

Get the analysis of a slippi file:
```json
{
  "t": "get",
  "slp_url": "https://slp-url.com"
}
```

### Server messages

#### Success messages

Everything went well (`data` is filled with slippi data):
```json
{
  "t": "done",
  "slp_url": "https://slp-url.com",
  "data": {}
}
```

#### Important errors

There was an error retrieving or parsing the file:
```json
{
  "t": "slp_error",
  "slp_url": "https://slp-url.com",
  "data": null
}
```

#### Debug errors

There was an error parsing the json:
```json
{
  "t": "json_error",
  "slp_url": null,
  "data": null
}
```

The command type is unknown:
```json
{
  "t": "unknown_command",
  "slp_url": "https://slp-url.com",
  "data": null
}
```

