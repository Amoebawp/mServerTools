# mFramework
### a Miscreated Modding Framework


All inclusive Lua Framework for Miscreated Mod Development

### Features:
- PersistantStorage
    - MisDB based JsonFile Based Persistant DataStorage 
- CustomEntity System
    - Add/Override new or existing Lua Methods on Vanilla or Modded Entities.
- CustomActions System
    - Add/Override Vanilla or Modded Scrollwheel and Inventory Actions for Both vanilla and Modded Items/Entities.
- RemoteEvents System
    - Custom RPC implementation Over RMI, Create and Listen for Remote Events on client and Server and React to them by
      providing your own Event Handler Methods.
- PluginManager
    - Create Custom "plugins" to extend or Change mFramework Functionality.
      this also allows for loading Sandboxed ServerSide only plugin Code with live reload support at runtime.
- TaskManager
    - Add/Remove/Start/Stop Simple Repeating Tasks by providing a task handler method
- LogManager
    - Custom Log Handler, logs to a seperate `mFramework.log` (Overidable for Custom logging)
- many usefull Pure Lua modules Pre-Included
- many usefull custom lua methods included for conveinience
- custom class system with some provided classes

