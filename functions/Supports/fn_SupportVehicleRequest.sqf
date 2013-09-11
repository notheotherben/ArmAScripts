/**
 * Support Vehicle Script
 * Allows a support vehicle (repair/rearm/refuel) to be called by the player.
 * It will then move to the player's position and wait for the player to rearm,
 * leaving only once the player has moved away from the support vehicle again.
 *
 * @author Benjamin Panell "SPARTAN"
 * @website https://sierrasoftworks.com
 * @licence MIT Licence
 *
 * @params [vehicle, target, radius, timeout]
 * @param vehicle The vehicle providing the support for the player
 * @param target The player or object which should receive the support (default: player)
 * @param radius A minimum radius which will be used to determine when a player is busy using the support vehicle (default: 50)
 * @usage _ = [support_ammo, player, getMarkerPos "depot"] execVM "Support\SupportVehicleRequest.sqf";
 */

private ["_vehicle", "_target", "_home_pos", "_wp1", "_rpos", "_radius"];

_vehicle = [_this, 0] call BIS_fnc_param;
_target = [_this, 1, player, [_vehicle,objnull]] call BIS_fnc_param;
_radius = [_this, 2, 30, [1]] call BIS_fnc_param;
_timeout = [_this, 3, 60, [1]] call BIS_fnc_param;

if(_vehicle getVariable "Sierra_support_tasked") exitWith {
	hint "Support Vehicle Busy";
};

_vehicle setVariable ["Sierra_support_tasked", true];

// Trick the vehicle into thinking it has already returned home
if (count waypoints group _vehicle > 0) then {
	(waypoints group _vehicle select count waypoints group _vehicle - 1) setWPPos getPosATL _vehicle;
};

// Remove all group waypoints
while {(count (waypoints group _vehicle)) > 0} do
{
	deleteWaypoint ((waypoints group _vehicle) select 0);
};

if(!(missionNamespace getVariable "Sierra_support_radio_busy")) then {
	missionNamespace setVariable ["Sierra_support_radio_busy", true];

	// Play the request radio stuff...
	player sidechat "Logistics, message. Over.";
	sleep 4.0;
	_vehicle sidechat "Send it. Over.";
	sleep 3.0;
	player sidechat "Request support at my location. How copy?";
	sleep 5.0;
	_vehicle sidechat "Good copy, vehicle deployed, standby. Out";

	missionNamespace setVariable ["Sierra_support_radio_busy", false];
};

// Give them a new move waypoint
_rpos = getPosATL _target;
_wp1 = group _vehicle addWaypoint [[(_rpos select 0) + _radius - random (2 * _radius), (_rpos select 1)  + _radius - random (2 * _radius), _rpos select 2], 0];
_wp1 setWaypointType "MOVE";
_wp1 setWaypointBehaviour "CARELESS";
_wp1 setWaypointSpeed "FULL";

// Wait for the vehicle to arrive at the waypoint
waitUntil { sleep 5; vehicle _vehicle distance _rpos < _radius };

_arrive_time = time;

if(vehicle _vehicle distance _target > 4 * _radius && !(missionNamespace getVariable "Sierra_support_radio_busy")) then {
	missionNamespace setVariable ["Sierra_support_radio_busy", true];

	_vehicle sidechat "Support has arrived at the arranged location, where are you?";
	sleep 8.0;

	missionNamespace setVariable ["Sierra_support_radio_busy", false];
};

// Wait for the player's vehicle to come in range
waitUntil { sleep 5; (vehicle _vehicle distance _target < 10 || time > (_arrive_time + _timeout)) };

// Wait for the resupply/repair/rearm to complete
waitUntil { sleep 5; (vehicle _vehicle distance _target > (2 * _radius) || time > (_arrive_time + _timeout)) };

// Remove all group waypoints
while {(count (waypoints group _vehicle)) > 0} do
{
	deleteWaypoint ((waypoints group _vehicle) select 0);
};

// Give them a new move waypoint
_rpos = _vehicle getVariable "Sierra_support_home";
_wp1 = group _vehicle addWaypoint [[(_rpos select 0) + _radius - random (2 * _radius), (_rpos select 1)  + _radius - random (2 * _radius), _rpos select 2], 0];
_wp1 setWaypointType "MOVE";
_wp1 setWaypointBehaviour "CARELESS";
_wp1 setWaypointSpeed "FULL";

_vehicle setVariable ["Sierra_support_tasked", false];