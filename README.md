# Story Progression module
 Story progression module for AGS(Adventure Game Studio)
 
  - Name: Story Progression module
  - Version: 0.1.0
  - AGS Version: 3.5.0.31
  - Author: Tarnos
  - This module let's you specify which object/hotspot/character is required next step in progressing the story(Click door, talk to character, use item on the door > wouldn't allow you to do that in any other order)
  - No dependencies, except the fact that all objects/characters/hotspots used with this module CAN'T have any Interaction/Use item events. + unhandled_events function in GlobalScript can't/shouldn't be used either as that will interfere with this system.

How to use:
StoryProgression.Add(LocationType, typeId, storyId, dialogId, emptyString(not used yet), roomId, interactionType(enum, not used currently), InventoryItem);
//Example:
StoryProgression.Add(eLocationCharacter, CHARACTER_EGO, 123, DIALOG_01, "", ROOM_MAIN, eInteract, null);
StoryProgression.Add(eLocationObject, OBJECT_DOOR, 123, DIALOG_NULL, "", ROOM_MAIN, eInteract, iKey);
StoryProgression.Add(eLocationObject, OBJECT_DOOR, 123, DIALOG_02, "", ROOM_MAIN, eInteract, null);
StoryProgression.Add(eLocationCharacter, CHARACTER_EGO, 123, DIALOG_03, "", ROOM_MAIN, eInteract, iCup);

For Characters you can pass -1 roomId since those don't use rooms, objects/hotspot need to have a room tho.
