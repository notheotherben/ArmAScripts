These are a number of useful scripts for mission designers. They provide everything from a realtime map (for example, from a UAV) to automatic support vehicle waypoints and logic. All scripts have been designed to be used with the new ArmA 3 function framework, giving you a number of advantages including anti-hack protection.

# Functions
## Map
### Sierra_fnc_PositionMarkers
Provides markers on a player's map indicating the positions of units satisfying a condition. By default, displays hostile units with an update interval of 10 seconds.

#### Examples
```
// Default Parameters
[true, 10, { side _x != side player }, "mil_dot"] call Sierra_fnc_PositionMarkers;

// Only show group leaders
[true, 10, { leader group _x == _x }, "mil_triangle"] call Sierra_fnc_PositionMarkers;
```

#### Parameters
- **enabled** Set to *true* to enable the map markers, or *false* to disable them for all connected clients.
- **interval** The amount of time to wait between client side updates. Server will update unit status (alive/dead) twice as often.
- **condition** Code to execute to determine whether a unit should be displayed on the player's map. Only checked when the command is first executed, to update you should call the command again.
- **style** The icon to use for each unit

## Supports
### Sierra_fnc_SupportVehicleInit
Allows a unit to be used to provide support on request. Essentially a more realistic version of a rearm script, since the vehicle will drive to the requested unit's position and wait for that unit to leave the position before it leaves. Takes into account the possibility that the requesting unit leaves the position before the support vehicle arrives, and allows configuration of the home base for the support vehicle.

#### Examples
```
// Default Parameters
[support_vehicle, getPosATL support_vehicle, true, true] call Sierra_fnc_SupportVehicleInit;

// Set a marker as the home base
[support_vehicle, getMarkerPos "depot", true, true] call Sierra_fnc_SupportVehicleInit;

// Allow the vehicle to be destroyed
[support_vehicle, getPosATL support_vehicle, false, true] call Sierra_fnc_SupportVehicleInit;

// Allow the vehicle to run out of supplies
[support_vehicle, getPosATL support_vehicle, true, false] call Sierra_fnc_SupportVehicleInit;
```

#### Parameters
- **vehicle** The vehicle which should provide support when requested. Should be AI controlled, however I guess it would work with a player as well.
- **home_position** The position that the vehicle should return to when finished providing support.
- **invincible** Whether or not the vehicle and crew will be invincible. Recommended you set this to false for vehicles capable of engaging the enemy.
- **infinite** Whether or not the vehicle's supplies will be infinite. Useful if you are resupplying a tank, which can easily empty an Ammo Truck.

# Licence
These scripts are all provided under the MIT Licence, which basically means that you are free to use and modify them however you like under the condition that you do not hold me liable for any problems you (or your users) encounter, and that you mention me as the source.