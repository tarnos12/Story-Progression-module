//Define hotspots/objects with their ID's

//Hotspots
#define HOTSPOT_ROOM_COUCH 6

//Objects
#define OBJECT_BOOTS 0

//Characters
#define CHARACTER_ROGER 0
#define CHARACTER_EGO 1

//Rooms
#define ROOM_NONE -1
#define ROOM_MAIN 1

//Dialogs
#define DIALOG_NULL -1
#define DIALOG_01 0
#define DIALOG_02 1


enum InteractionType {
    eInteract, 
    eUseItem
};



struct StoryProgression{
    int objectId;
    int hotspotId;
    int characterId;
    int roomId;//Needed with objects/hotspots since those belong to specific room.
    int dialogId;
    String cutAwayName;
    InteractionType interactionType;
    int ID;//id of the story, this is NOT and index of an array but an actual ID to reference story from excel or something.
    InventoryItem *item;//item required to be used if interaction type says so.
    
    
    import static void Add(LocationType type, int typeId, int storyId, int dialogId, String cutAwayName, int roomId, InteractionType interactionType, InventoryItem *item);
    
    import void Init();
    import void Execute();//Executes the story to move forward
};


import function StoryInteractObject(int storyId, int dialogID, String cutAwayName, String objectName, int roomId);
import function StoryUseItemOnObject(int storyId, int dialogID, String cutAwayName, String objectName, int roomId, InventoryItem *itemRequired);
import function StoryInteractHotspot(int storyId, int dialogID, String cutAwayName, String hotspotName, int roomId);
import function StoryUseItemOnHotspot(int storyId, int dialogID, String cutAwayName, String hotspotName, int roomId, InventoryItem *itemRequired);
import function StoryInteractCharacter(int storyId, int dialogID, String cutAwayName, Character *characterRef);
import function StoryUseItemOnCharacter(int storyId, int dialogID, String cutAwayName, Character *characterRef, InventoryItem *itemRequired);