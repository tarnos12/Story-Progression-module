AGSScriptModule        ?$  #define STORY_PARTS 2000
// Story progression system, used with linear story. Set scene to be played when interacting with specific object/hotspot/character etc.
/*
Ways to access data with id 2:
character[2];
character[2].Room;
object[2];
hotspot[2];
*/
int currentStoryProgression = 0;
//objects & hotspots in current room
Dictionary* storyObjects;
Dictionary* storyHotspots;
//not storing characters, because those are global

Dictionary* storyObjectDefaultText;
Dictionary* storyHotspotDefaultText;

Dictionary* defaultDialogsPerCharacter;//charId, dialogId

int freeStorySlot = 0;//used to fill the array at correct index since there is no "push"
StoryProgression Story[STORY_PARTS];


bool isInRange(int min, int max, int value){
    if(value >= min && value <= max) return true;
    return false;
}

//Once I figure out how to use custom events so I can invoke them, then I would allow for custom functions to handle the state
//Bur for now, we have to do all in here:
//Used with Objects/Hotspots to set their custom text.
//This will repeat each time the story is executed and will keep repeating certain actions if the conditions match.
function UpdateGameState(){
    int storyId = Story[currentStoryProgression].ID;
    int objectId = Story[currentStoryProgression].objectId;
    int hotspotId = Story[currentStoryProgression].hotspotId;
    int characterId = Story[currentStoryProgression].characterId;
    int roomId = Story[currentStoryProgression].roomId;
    int dialogId = Story[currentStoryProgression].dialogId;
    String cutAwayName = Story[currentStoryProgression].cutAwayName;
    
    //Default setup for all objects/hotspots
    /*
    if(isInRange(1000, 1000, storyId)){
        //set objects default text
        storyObjectDefaultText.Set("oBoots", "Why is this floating boot doing here?!!");
        //set hotspots default text
        storyHotspotDefaultText.Set("Couch hotspot", "I should not touch this couch");
    }
    if(isInRange(1002, 1002, storyId)){
        String bootObj = storyObjects.Get("oBoots");
        int bootId = bootObj.AsInt;
        object[bootId].Move(200, 100, 10, eNoBlock, eAnywhere);
        storyObjectDefaultText.Set("oBoots", "Weird...");
    }
    if(isInRange(1003, 1003, storyId)){
        cEgo.Walk(50, cEgo.y, eBlock, eWalkableAreas);
    }
    */
}

GUIControl *questLabel;

void StoryProgression::Init(){
    this.objectId = -1;
    this.hotspotId = -1;
    this.characterId = -1;
    this.roomId = -1;
    this.dialogId = -1;
    this.cutAwayName = "";
    this.interactionType = eInteract;
    this.ID = -1;
}

void StoryProgression::Execute(){
    //play the story i.e. dialog
    if(this.dialogId >= 0) dialog[this.dialogId].Start();
    currentStoryProgression++;//progress the story.
    UpdateGameState();
}

static void StoryProgression::Add(LocationType type, int typeId, int storyId, int dialogId, String cutAwayName, int roomId, InteractionType interactionType, InventoryItem *item){
    if(freeStorySlot >= STORY_PARTS - 1) {
        Display("Reached story limit, can't add more");
        return;
    }
    Story[freeStorySlot].Init();
    
    Story[freeStorySlot].roomId = roomId;
    Story[freeStorySlot].dialogId = dialogId;
    Story[freeStorySlot].ID = storyId;
    Story[freeStorySlot].cutAwayName = cutAwayName;
    Story[freeStorySlot].interactionType = interactionType;
    Story[freeStorySlot].item = item;
    if(item != null) Story[freeStorySlot].item = item;
    if(type == eLocationCharacter){
        Story[freeStorySlot].characterId = typeId;
    }
    else if(type == eLocationHotspot){
        Story[freeStorySlot].hotspotId = typeId;
    }
    else if(type == eLocationObject){
        Story[freeStorySlot].objectId = typeId;
    }
    freeStorySlot++;//increment story slot before next one is added to the array.
}

static void StoryProgression::AddDefaultDialogs(Character *characterRef, Dialog *dialogRef){
    defaultDialogsPerCharacter.Set(String.Format("%d",characterRef.ID), String.Format("%d",dialogRef.ID));
}

static void StoryProgression::InitializeQuestSystem(GUIControl *label){
    questLabel = label;
}

static void StoryProgression::UpdateQuest(){
    if(questLabel == null) return;
    questLabel.AsLabel.Text = "";
    
    String nameTxt = "";
    int id = currentStoryProgression;
    
    if(Story[id].characterId >= 0){
        nameTxt = character[Story[id].characterId].Name;
    }
    if(Story[id].hotspotId >= 0){
        nameTxt = hotspot[Story[id].hotspotId].Name;
    }
    if(Story[id].objectId >= 0){
        nameTxt = object[Story[id].objectId].Name;
    }
    if(Story[id].item != null){
        questLabel.AsLabel.Text = questLabel.AsLabel.Text.Append(String.Format("Use %s on ", Story[id].item.Name));
    }
    else{
        questLabel.AsLabel.Text = questLabel.AsLabel.Text.Append("Click on ");
    }
    questLabel.AsLabel.Text = questLabel.AsLabel.Text.Append(nameTxt);
}

static int StoryProgression::GetCurrentStoryId(){
    return Story[currentStoryProgression].ID;
}

static bool StoryProgression::IsStoryInRange(int min, int max){
    return isInRange(min, max, StoryProgression.GetCurrentStoryId());
}
//===========================================================================
//
// game_start()
// Setup the Story array and Init it's values.
//
//===========================================================================
function game_start(){
    //Story = new Story[STORY_PARTS];
    for(int i = 0; i < STORY_PARTS; i++){
        Story[i].Init();
    }
    defaultDialogsPerCharacter = Dictionary.Create(eSorted);
}

//===========================================================================
//
// on_mouse_click (MouseButton button)
// Handle the event of player interacting with objects/hotspots/characters
// Used with the story progression system
//
//===========================================================================
function on_mouse_click (MouseButton button)
{
    if(button != eMouseLeft) return;
    LocationType locationType = GetLocationType(mouse.x, mouse.y);
    //hotspot interaction + use item
    if(locationType == eLocationHotspot)
    {
        Hotspot *hotspotRef = Hotspot.GetAtScreenXY(mouse.x, mouse.y);
        int hotspotId = Story[currentStoryProgression].hotspotId;
        int roomId = Story[currentStoryProgression].roomId;
        bool haveItem = true;
        InventoryItem *itemNeeded = Story[currentStoryProgression].item;
        if(player.ActiveInventory != itemNeeded) haveItem = false;
        
        if(hotspotId == hotspotRef.ID && roomId == player.Room && haveItem){
            Story[currentStoryProgression].Execute();
        }
        else {
            String text = storyHotspotDefaultText.Get(hotspotRef.Name);
            if(text != null){
                player.Say(text);
            }
        }
    }
    //object interaction + use item
    if(locationType == eLocationObject)
    {
        Object *objectRef = Object.GetAtScreenXY(mouse.x, mouse.y);
        int objectId = Story[currentStoryProgression].objectId;
        int roomId = Story[currentStoryProgression].roomId;
        bool haveItem = true;
        InventoryItem *itemNeeded = Story[currentStoryProgression].item;
        if(player.ActiveInventory != itemNeeded) haveItem = false;
        
        if(objectId == objectRef.ID && roomId == player.Room && haveItem){
            Story[currentStoryProgression].Execute();
        }
        else {
            String text = storyObjectDefaultText.Get(objectRef.Name);
            if(text != null){
                player.Say(text);
            }
        }

    }
    //character interaction + use item
    if(locationType == eLocationCharacter)
    {
        Character *characterRef = Character.GetAtScreenXY(mouse.x, mouse.y);
        int characterId = Story[currentStoryProgression].characterId;
        bool haveItem = true;
        InventoryItem *itemNeeded = Story[currentStoryProgression].item;
        if(player.ActiveInventory != itemNeeded) haveItem = false;
        //Not comparing to a room since characters can be anywhere.
        if(characterId == characterRef.ID && haveItem){
            Story[currentStoryProgression].Execute();
        }
        else{
            String dialogId = defaultDialogsPerCharacter.Get(String.Format("%d",characterRef.ID));
            if(dialogId != null){
                dialog[dialogId.AsInt].Start();
            }
        }
    }
    StoryProgression.UpdateQuest();
}

function on_event (EventType event, int data){
    if(event == eEventEnterRoomBeforeFadein){
        storyObjects = Dictionary.Create(eSorted);
        storyObjectDefaultText = Dictionary.Create(eSorted);
        storyHotspots = Dictionary.Create(eSorted);
        storyHotspotDefaultText = Dictionary.Create(eSorted);
        for(int i = 0; i < Room.ObjectCount; i++){
            storyObjects.Set(object[i].Name, String.Format("%d",object[i].ID));
        }
        for(int i = 0; i < AGS_MAX_HOTSPOTS; i++){
            storyHotspots.Set(hotspot[i].Name, String.Format("%d",hotspot[i].ID));
        }
        StoryProgression.UpdateQuest();
        UpdateGameState();
    }
} ?  //Define hotspots/objects with their ID's


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
    import static void AddDefaultDialogs(Character *characterRef, Dialog *dialogRef);
    import static void InitializeQuestSystem(GUIControl *label);
    import static void UpdateQuest();
    import static int GetCurrentStoryId();
    import static bool IsStoryInRange(int min, int max);
    
    import void Init();
    import void Execute();//Executes the story to move forward
}; |        ej??