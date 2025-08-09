
# context7 mcp

```json

{
  
  "mcpServers": {    
    "context-7": {
      "command": "npx",
      "args": [
        "-y",
        "@upstash/context7-mcp@latest"
      ],
      "env": {}
    }
  }
}


```

# filesystem mcp

```json

{
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "your/path/to/your/project"
      ],
      "env": {}
    },
}

```

# memory mcp

```json

{
    "memory": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-memory"
      ],
      "env": {
        "MEMORY_FILE_PATH": "your/path/to/your/project/memory.json"
      }
    },

```


# sequential-thinking mcp

```json

{
    "sequential-thinking": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-sequential-thinking"
      ]
    }
  }


```
