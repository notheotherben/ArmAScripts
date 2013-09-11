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
 * @params [vehicles, home_position]
 * @param vehicles The vehicles providing the support for the player
 * @param home_position The position that the vehicle should return to (default: getPosATL (_vehicles select 0))
 * @usage _ = [support_ammo, getMarkerPos "depot"] call Sierra_fnc_SupportVehicleInit;
 */


if(!isServer) exitWith {};

private ["_vehicles", "_home"];

_vehicles = [_this, 0] call BIS_fnc_param;

if(typeName _vehicles != "ARRAY") then {
	_vehicles = [_vehicles];
};

_home = [_this, 1, getPosATL (_vehicles select 0)] call BIS_fnc_param;

{ 
	_x setVariable ["Sierra_support_home", _home];
	if(!(_x getVariable "Sierra_support_tasked")) then {
		_wp1 = group _x addWaypoint [_home, 0];
		_wp1 setWaypointType "MOVE";
		_wp1 setWaypointBehaviour "CARELESS";
		_wp1 setWaypointSpeed "FULL";
	};
} forEach _vehicles;

