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
 * @params [vehicle, home_position, invincible, infinite]
 * @param vehicle The vehicle providing the support for the player
 * @param home_position The position that the vehicle should return to (default: getPosATL vehicle)
 * @param invincible Whether or not the support vehicle can be killed (default: true)
 * @param infinite Whether or not the resupply vehicle provides an infinite supply of whatever (default: true)
 * @usage _ = [support_ammo, getMarkerPos "depot", true, true] call Sierra_fnc_SupportVehicleInit;
 */

if(!isServer) exitWith {};

private ["_vehicle", "_home", "_invincible"];

_vehicle = [_this, 0] call BIS_fnc_param;
_home = [_this, 1, getPosATL _vehicle, [[]], [3]] call BIS_fnc_param;
_invincible = [_this, 2, true, [true]] call BIS_fnc_param;
_infinite = [_this, 3, true, [true]] call BIS_fnc_param;

if(_invincible) then {
	{
		_x allowDamage false;
	} forEach [vehicle _vehicle] + crew vehicle _vehicle;
};

_vehicle setVariable ["Sierra_support_tasked", false];
_vehicle setVariable ["Sierra_support_home", _home];
missionNamespace setVariable ["Sierra_support_radio_busy", false];

if(_infinite) then {
	[_vehicle] spawn {
		_vehicle = _this select 0;
		while(true) {
			sleep 2;
			_vehicle setAmmoCargo 1;
			_vehicle setFuelCargo 1;
			_vehicle setRepairCargo 1;
		}
	}
};