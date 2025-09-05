
# context7 mcp

# sequential-thinking mcp

# memory mcp


# filesystem mcp

```json

{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-memory"
      ],
      "env": {
        "MEMORY_FILE_PATH": "C:/Users/code4/Desktop/atlas_ai/memory.json"
      }
    },
    
    "sequential-thinking": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-sequential-thinking"
      ]
    },
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "c:/Users/code4/Desktop/atlas_ai"
      ],
      "env": {}
    },
          "context7": {
        "url": "https://mcp.context7.com/mcp"
      }
    }
  }
```