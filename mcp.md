
# memory mcp

```json


{ "mcpServers": {    
    "context-7": {
      "command": "npx",
      "args": [
        "-y",
        "@upstash/context7-mcp@latest"
      ],
      "env": {}
    },
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "C:/Users/alrom/Documents/Fine_tuning_AI"
      ],
      "env": {}
    },
    "memory": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-memory"
      ],
      "env": {
        "MEMORY_FILE_PATH": "C:/Users/alrom/Documents/Fine_tuning_AI/Cursor_memory.json"
      }
    },
    "sequential-thinking": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-sequential-thinking"
      ]
    }
  }
}
```
