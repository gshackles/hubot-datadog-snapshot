# hubot-datadog-snapshot

Hubot script for querying Datadog graph snapshots

For a quick introduction to this script and to see examples of it in action, [check out this blog post](http://www.gregshackles.com/querying-datadog-graphs-from-hubot/).

## Installation

First, in your Hubot repository run:

`npm install hubot-datadog-snapshot --save`

Next, add `hubot-datadog-snapshot` to your `external-scripts.json` file:

```
[
  // ...,
  "hubot-datadog-snapshot"
]
```

## Configuration

There are a couple pieces of required configuration to get things working:

- **`HUBOT_DATADOG_API_KEY`**: Your Datadog API key
- **`HUBOT_DATADOG_APP_KEY`**: Your Datadog app key

You can set these up in your [Datadog dashboard](https://app.datadoghq.com/account/settings#api).

There is also one optional piece of configuration:

- **`HUBOT_DATADOG_GRAPH_RESPONSE_DELAY`**: time to pause (in milliseconds) in between receiving a graph URL from Datadog and sending it to the room

The reason for this option is that even though Datadog will return a URL right away, often it takes a second or two for the graph to actually be available. This can result in the image not automatically loading when the message is received in something like Slack or HipChat because the request would fail. The default value for this is 2 seconds.

## Example Interactions

### Querying with Datadog's Query Language

To get started you can take a query from your Datadog dashboard and run it here:

```
greg> hubot datadog query 24h avg:system.cpu.user
hubot> https://datadog/url
```

The time period can be defined in seconds (`s`), minutes (`m`), hours (`h`), or days (`d`). You can also omit the time period and it will default to one hour.

### Saving a Query

Hubot will always keep track of the last query requested by each user, making it simple to save it for future use. This is done on a per-user basis so there's no need to worry about multiple users querying things at once. This is the only user-specific interaction, so all other commands (including the saved queries themselves) are globally available.

To save a query:

```
greg> hubot datadog save that as cpu
hubot> Shell: I saved that graph for you as `cpu`
```

### Listing Saved Queries

You can also easily pull a list of all saved queries:

```
greg> hubot datadog list
hubot> I have the following saved queries :sparkles:

cpu
```

### Running a Saved Query

You can also use the same query syntax from earlier to run saved queries by providing the name of that query instead of the Datadog query itself:

```
greg> hubot datadog query cpu
hubot> https://datadog/url
```

The time period specification is identical as well, and also defaults to one hour.

```
greg> hubot datadog query 7d cpu
hubot> https://datadog/url
```

### Describing a Saved Query

Forgot what the actual query is behind one of your saved queries? No problem!

```
greg> hubot datadog describe cpu
hubot> Shell: That query is defined as `avg:system.cpu.user`
```

### Deleting a Saved Query

You can quickly delete a saved query as well:

```
greg> hubot datadog delete cpu
hubot> Shell: I deleted the query `cpu`
```

### Shorthand

For all of these commands you have the option of using `hubot dd` instead of `hubot datadog` as a convenient shorthand to save those valuable keystrokes.
