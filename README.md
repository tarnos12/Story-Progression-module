# Story Progression module
 Story progression module for AGS(Adventure Game Studio)
- Plain text (*.txt) or html file for maximum compatibility
- Same name as module/plugin
- Should contain the following:
  - Story Progression module
  - 0.1.0
  - Tarnos
  - Module let's you specify which object/hotspot/character is next step in progressing the story(Click door, talk to character, use item on the door > wouldn't allow you to do that in any other order)
  - No dependencies, except the fact that all objects/characters/hotspots used with this module CAN'T have any Interaction/Use item on events. + unhandled_events function in GlobalScript can't/shouldn't be used either as that will interfere with this system.
  
  All you have to do is use this static function to Add story parts:
StoryProgression.Add(LocationType, typeId, storyId, dialogId, emptyString(not used yet), roomId, interactionType(enum, not used currently), InventoryItem);
Example:
StoryProgression.Add(eLocationCharacter, CHARACTER_EGO, 123, DIALOG_01, "", ROOM_MAIN, eInteract, iKey);
This example uses #define values which you can see in the header
Location Object/Hotspot are REQUIRED to have room id specified, Characters don't because those are global.(objects/hotspots are per room)
Pass -1 if not used or null for item
All objects/hotspots/items/characters can't have interaction/use item events attached to them.
Soon when I update this module, you will be able to specify further what message is displayed when interacting with an object currently not used in the story
